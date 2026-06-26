# KPZ308 rPVA Practical Dev Image Ready For ITS Staging

Hi Mark,

The first controlled dev image for the KPZ308 rPVA Practical 1 Shiny app has
been built, smoke-tested locally in WSL, and pushed to the ITS Gitea registry.

- Image: `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748`
- Digest: `sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340`
- Source commit: `9524304fb74805baad7672f81f219b8455a4aac8`
- Local WSL smoke: passed on `127.0.0.1:3904`

No secrets, credentials, or student data are included in this note.

Could you please link/deploy this image to the ITS dev server when ready, and
return:

- the dev URL;
- the expected SSO/access group;
- the service-user home path for persistent app data;
- the deployment directory;
- the restart path Barry should use;
- whether future ShinyProxy config should pin images by tag or by digest.
