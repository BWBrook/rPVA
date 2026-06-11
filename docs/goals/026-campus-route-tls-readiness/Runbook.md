# Runbook

This runbook is guidance for Goal 026 diagnostics. Adapt paths and commands as
needed, but do not broaden the goal or modify live service state.

## Local Guard

```sh
pwd
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected:

```text
branch: codex/rpva-goal026-campus-tls-readiness
HEAD/origin-main base: 7b0e3fb Record Practical 1 non-student staging bootstrap
```

## Remote Posture Checks

Do not print secrets.

```sh
ssh deep-server-ts '
set -eu
printf "host=%s\n" "$(hostname)"
printf "shinyproxy=%s\n" "$(systemctl is-active shinyproxy)"
printf "nginx=%s\n" "$(systemctl is-active nginx)"
ss -ltnp | awk "/127[.]0[.]0[.]1:3838|:443/ {print}"
docker image inspect rpva-practical1:goal025-5c9d500 \
  --format "image_id={{.Id}} size={{.Size}} created={{.Created}}"
stat -c "%U:%G %a %n" \
  /data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt \
  /etc/shinyproxy/application.yml \
  /opt/shinyproxy/shinyproxy-3.2.4.jar
'
```

Redacted ShinyProxy config shape, if needed:

```sh
ssh deep-server-ts "sudo perl -ne 'next if /password|secret|credential|token|passwd/; print if /server:|port:|address:|forward-headers-strategy|proxy:|authentication:|admin-groups|users:|name:|groups:|specs:|id:|display-name:|container-image:/' /etc/shinyproxy/application.yml"
```

Read-only nginx route shape, if needed:

```sh
ssh deep-server-ts "sudo nginx -T 2>/dev/null | perl -ne 'next if /ssl_certificate_key/; print if /server_name|listen|location|proxy_pass|proxy_set_header|ssl_certificate/'"
```

Do not cat private keys. Do not copy certificate private keys.

## Route Checks

Tailnet:

```sh
curl -k -sS -o /tmp/rpva-goal026-tailnet-health.txt \
  -w "tailnet_health=%{http_code} %{url_effective}\n" \
  --max-time 10 https://100.96.185.60/_gateway-health

curl -k -sS -I --max-time 10 https://100.96.185.60/login | sed -n '1,12p'
```

Campus/public IP from the Mac mini:

```sh
curl -k -sS -o /tmp/rpva-goal026-campus-health.txt \
  -w "campus_health=%{http_code} %{url_effective}\n" \
  --max-time 10 https://131.217.90.193/_gateway-health || true

curl -k -sS -I --max-time 10 https://131.217.90.193/login | sed -n '1,12p' || true
```

Do not loop or load-test if the campus/public-IP route times out from this
origin. Record it as a local-origin result and separately record Barry's
campus-origin observation from the Goal.

## TLS Certificate Inspection

Use read-only certificate inspection. These commands must not read private key
files.

```sh
echo | openssl s_client -connect 100.96.185.60:443 -servername 100.96.185.60 \
  -showcerts 2>/tmp/rpva-goal026-tailnet-s_client.err |
  openssl x509 -noout -subject -issuer -dates -ext subjectAltName

cat /tmp/rpva-goal026-tailnet-s_client.err | sed -n '1,40p'
```

```sh
echo | openssl s_client -connect 131.217.90.193:443 -servername 131.217.90.193 \
  -showcerts 2>/tmp/rpva-goal026-campus-s_client.err |
  openssl x509 -noout -subject -issuer -dates -ext subjectAltName

cat /tmp/rpva-goal026-campus-s_client.err | sed -n '1,40p'
```

If the `openssl x509` pipeline fails because no certificate is returned, record
the exact failure and do not keep probing aggressively.

## Authenticated Tailnet Check

Use the existing staging credential without printing it.

```sh
set -eu
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
pw=$(ssh deep-server-ts 'cat /data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt')
curl -sk -c "$tmp/cookies" -o "$tmp/login.html" https://100.96.185.60/login
csrf=$(perl -0777 -ne 'print $1 if /name="_csrf"[^>]*value="([^"]+)"|value="([^"]+)"[^>]*name="_csrf"/' "$tmp/login.html")
test -n "$csrf"
curl -sk -b "$tmp/cookies" -c "$tmp/cookies" -L -o "$tmp/post-login.html" \
  -w "tailnet_login=%{http_code} %{url_effective}\n" \
  --data-urlencode "username=rpva_goal025_nonstudent" \
  --data-urlencode "password=$pw" \
  --data-urlencode "_csrf=$csrf" \
  https://100.96.185.60/login
curl -sk -b "$tmp/cookies" -L -o "$tmp/app.html" \
  -w "tailnet_app=%{http_code} %{url_effective}\n" \
  https://100.96.185.60/app/practical1
grep -Eq "Practical 1|PVA|Compare|Concept Lab" "$tmp/app.html" &&
  echo tailnet_app_marker_ok
```

Do not echo `$pw`. Do not save the temp directory. Do not put generated HTML in
the repo.

## Browser Evidence

If Browser, Chrome, or Playwright is used:

- capture only non-secret pages, such as the certificate warning or login page;
- do not type or screenshot credentials;
- save screenshots under `/tmp`;
- record paths in the report;
- remove tool-generated repo-local artifacts if the browser tooling creates
  them.

## Validation

```sh
git status --short --branch
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Marker scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret-pattern scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Manually confirm any scan hits are policy wording, credential-path references,
or redacted diagnostics only.
