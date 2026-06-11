# Runbook

This runbook supports Goal 027. Adapt commands as needed, but do not broaden
the goal or print secrets/private keys.

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
branch: codex/rpva-goal027-trusted-class-hostname-tls
HEAD/origin-main base: 20f18c3 Record campus route TLS readiness diagnostics
```

## Remote Posture

```sh
ssh deep-server-ts '
set -eu
printf "host=%s\n" "$(hostname)"
printf "shinyproxy=%s\n" "$(systemctl is-active shinyproxy)"
printf "nginx=%s\n" "$(systemctl is-active nginx)"
ss -ltnp | grep -E "3838|:443" || true
stat -c "%U:%G %a %n" \
  /data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt \
  /etc/shinyproxy/application.yml \
  /etc/ssl/certs/ssl-cert-snakeoil.pem \
  /etc/ssl/private/ssl-cert-snakeoil.key
'
```

Do not print the credential or private-key contents.

## Redacted Nginx And ShinyProxy Shape

```sh
ssh deep-server-ts "sudo nginx -T 2>/dev/null | perl -ne 'next if /ssl_certificate_key/; print if /server_name|listen|location|proxy_pass|proxy_set_header|ssl_certificate/'"
```

```sh
ssh deep-server-ts "sudo perl -ne 'next if /password|secret|credential|token|passwd/; print if /server:|port:|address:|forward-headers-strategy|proxy:|authentication:|admin-groups|users:|name:|groups:|specs:|id:|display-name:|container-image:/' /etc/shinyproxy/application.yml"
```

## Hostname Discovery

Collect candidate names from:

- nginx `server_name`;
- hostnames known to `hostname`, `hostname -f`, and `/etc/hosts`;
- repo-local Goal 026 report;
- any existing certificate SAN entries.

Suggested commands:

```sh
ssh deep-server-ts '
set -eu
hostname
hostname -f || true
getent hosts deep-server || true
getent hosts utas-ubuntu || true
getent hosts utas-ubuntu.tail77f589.ts.net || true
'
```

From the Mac mini:

```sh
for name in deep-server utas-ubuntu utas-ubuntu.tail77f589.ts.net; do
  printf "%s " "$name"
  dscacheutil -q host -a name "$name" 2>/dev/null | sed -n "1,4p" || true
done
```

If another candidate hostname appears in live config, check it too. Do not
invent a student hostname if DNS ownership is unknown.

## Certificate Metadata

Public certificate metadata only:

```sh
ssh deep-server-ts 'openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -noout -subject -issuer -dates -ext subjectAltName -fingerprint -sha256'
```

Check common existing certificate directories without printing private keys:

```sh
ssh deep-server-ts '
set -eu
for dir in /etc/letsencrypt/live /etc/ssl/certs /etc/ssl/private /var/lib/tailscale/certs; do
  test -d "$dir" && sudo find "$dir" -maxdepth 2 -type f -printf "%M %u:%g %p\n" | sort | sed -n "1,80p"
done
'
```

If private key paths appear, report paths and permissions only.

## Certificate Mechanism Discovery

Read-only command discovery:

```sh
ssh deep-server-ts '
command -v certbot || true
command -v tailscale || true
command -v acme.sh || true
test -f /etc/letsencrypt/cli.ini && stat -c "%U:%G %a %n" /etc/letsencrypt/cli.ini || true
'
```

Do not install certificate tooling in this goal unless all conditional gates in
`Goal.md` are satisfied.

## Route Checks

Tailnet baseline:

```sh
curl -k -sS -o /tmp/rpva-goal027-tailnet-health.txt \
  -w "tailnet_health=%{http_code} %{url_effective}\n" \
  --max-time 10 https://100.96.185.60/_gateway-health
```

Candidate hostname checks:

```sh
candidate="$RPVA_TLS_CANDIDATE"
test -n "$candidate"
curl -sS -I --max-time 10 "https://$candidate/login" | sed -n '1,12p' || true
echo | openssl s_client -connect "$candidate:443" -servername "$candidate" \
  -showcerts 2>/tmp/rpva-goal027-s_client.err |
  openssl x509 -noout -subject -issuer -dates -ext subjectAltName || true
sed -n '1,80p' /tmp/rpva-goal027-s_client.err
```

Set `RPVA_TLS_CANDIDATE` to the recorded candidate hostname before running the
check, and record the exact value in `Log.md`.

## Conditional Nginx/TLS Change

Only use this section if every conditional gate in `Goal.md` passes.

Before editing:

```sh
ssh deep-server-ts '
set -eu
stamp=$(date -u +%Y%m%dT%H%M%SZ)
sudo cp /etc/nginx/sites-enabled/default "/etc/nginx/sites-enabled/default.rpva-goal027.$stamp.bak"
sudo nginx -T >/tmp/rpva-goal027-nginx-before.txt 2>/tmp/rpva-goal027-nginx-before.err
sudo nginx -t
printf "backup=/etc/nginx/sites-enabled/default.rpva-goal027.%s.bak\n" "$stamp"
'
```

After a minimal edit:

```sh
ssh deep-server-ts 'sudo nginx -t'
```

Reload only after syntax validation:

```sh
ssh deep-server-ts 'sudo systemctl reload nginx && systemctl is-active nginx'
```

Record exact edited file, backup path, certificate paths, validation output, and
rollback commands.

Rollback shape if nginx config was edited:

```sh
ssh deep-server-ts '
set -eu
backup="$RPVA_GOAL027_NGINX_BACKUP"
test -f "$backup"
sudo cp "$backup" /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
'
```

Set `RPVA_GOAL027_NGINX_BACKUP` to the actual backup path if a live edit occurs.

## Authenticated App And Export Smoke

Only after a trusted candidate URL is available.

Use the existing staging credential without printing it:

```sh
set -eu
candidate="$RPVA_TLS_CANDIDATE"
test -n "$candidate"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
pw=$(ssh deep-server-ts 'cat /data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt')
curl -sS -c "$tmp/cookies" -o "$tmp/login.html" "https://$candidate/login"
csrf=$(perl -0777 -ne 'print $1 if /name="_csrf"[^>]*value="([^"]+)"|value="([^"]+)"[^>]*name="_csrf"/' "$tmp/login.html")
test -n "$csrf"
curl -sS -b "$tmp/cookies" -c "$tmp/cookies" -L -o "$tmp/post-login.html" \
  -w "trusted_login=%{http_code} %{url_effective}\n" \
  --data-urlencode "username=rpva_goal025_nonstudent" \
  --data-urlencode "password=$pw" \
  --data-urlencode "_csrf=$csrf" \
  "https://$candidate/login"
curl -sS -b "$tmp/cookies" -L -o "$tmp/app.html" \
  -w "trusted_app=%{http_code} %{url_effective}\n" \
  "https://$candidate/app/practical1"
grep -Eq "Practical 1|PVA|Compare|Concept Lab" "$tmp/app.html" &&
  echo trusted_app_marker_ok
```

If browser automation is used, do not screenshot credentials and save evidence
under `/tmp`.

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

Secret/private-key scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Manually confirm scan hits are policy wording, command text, credential-path
references, private-key path references, or redacted diagnostics only.
