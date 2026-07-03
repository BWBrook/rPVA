# WSL Image Push Runbook For ITS Dev Server

This runbook is for Barry's WSL machine on GlobalProtect VPN. The Mac mini
remains the rPVA project command centre. WSL is only the human-assisted
campus/VPN publishing lane because it can reach ITS Gitea.

Do not run these commands on the Mac mini. Do not paste passwords or tokens
into documents, chat, shell history captures, or repo files.

## Confirmed Publication Target

Source repository:

```text
https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git
```

Registry image path:

```text
git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>
```

Use lowercase `utas` in Docker image references. The source repository URL
still uses `UTAS/kpz308-rpva-practical.git`.

ITS dev-server Docker network:

```text
shinyproxy-net
```

## Source Tree Options

Use a reviewed rPVA commit from the Mac mini source-of-truth checkout.

Option A, receive a source archive prepared on the Mac mini:

```sh
mkdir -p "$HOME/rpva-publish/kpz308-rpva-practical"
tar -xzf "$HOME/Downloads/rpva-<REVIEWED_COMMIT>.tar.gz" \
  -C "$HOME/rpva-publish/kpz308-rpva-practical" \
  --strip-components=1
cd "$HOME/rpva-publish/kpz308-rpva-practical"
```

Option B, if WSL has approved GitHub access, clone the reviewed GitHub source:

```sh
mkdir -p "$HOME/rpva-publish"
cd "$HOME/rpva-publish"
git clone git@github.com:BWBrook/rPVA.git kpz308-rpva-practical
cd kpz308-rpva-practical
git fetch --prune origin
git checkout <REVIEWED_COMMIT_OR_TAG>
git status --short --branch
```

Do not clone from ITS Gitea unless a later goal explicitly authorizes that
source path.

## Build A Linux AMD64 Image

Choose an immutable tag that includes the source commit or date. Avoid
`latest`.

```sh
REVIEWED_REF=<REVIEWED_COMMIT_OR_TAG>
TAG=dev-<YYYYMMDD>-<SHORT_SHA>
IMAGE="git.its.utas.edu.au/utas/kpz308-rpva-practical:${TAG}"

docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF="${REVIEWED_REF}" \
  -t "${IMAGE}" \
  .
```

Optional pre-push local smoke in WSL:

```sh
docker run --rm -d \
  --name rpva-practical-smoke \
  -p 3838:3838 \
  "${IMAGE}"

curl -fsS http://127.0.0.1:3838/ >/tmp/rpva-practical-smoke.html
grep -E "KPZ308|Practical|rPVA|Shiny" /tmp/rpva-practical-smoke.html
docker rm -f rpva-practical-smoke
```

## Log In Without Leaking Tokens

Use a Gitea username and token/password supplied through an approved human
channel. Do not put the token/password directly on a command line.

```sh
read -rp "Gitea username: " GITEA_USER
read -rsp "Gitea token or password (input hidden): " GITEA_TOKEN
printf '\n'
printf '%s' "${GITEA_TOKEN}" | docker login git.its.utas.edu.au \
  --username "${GITEA_USER}" \
  --password-stdin
unset GITEA_TOKEN
```

If login fails, stop and report the exact error class without pasting the
token/password anywhere.

## Push And Record Digest

```sh
if ( set -o pipefail; docker push "${IMAGE}" | tee "push-${TAG}.log" ); then
  echo "push succeeded"
else
  echo "push failed; do not request deployment" >&2
  exit 1
fi
grep -E "digest: sha256:" "push-${TAG}.log"
```

If available, also query the registry manifest:

```sh
docker buildx imagetools inspect "${IMAGE}" | tee "manifest-${TAG}.txt"
```

Prepare a non-secret return note for Mark:

```sh
cat > "mark-image-${TAG}.txt" <<EOF
Image: ${IMAGE}
Source ref: ${REVIEWED_REF}
Push log: push-${TAG}.log
Manifest record: manifest-${TAG}.txt if available
Digest: paste sha256 digest from push log or manifest output here
Notes: built from reviewed rPVA source; no secrets or student data included
EOF
```

Send Mark only the image tag, digest, source ref, and any non-secret smoke
result. Do not send tokens, local shell history, full credential prompts, image
layers, or student identifiers.

## Promotion Policy

Use the agreed dev-first, prod-second promotion path:

1. push a new readable immutable tag to Gitea;
2. update dev `application.yml`;
3. smoke dev;
4. update prod `application.yml` to the same tag;
5. smoke prod.

Mark prefers readable immutable tags in config rather than digest pins. Record
digests for provenance and rollback evidence.
