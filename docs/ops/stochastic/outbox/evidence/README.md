# Evidence Hygiene For `stochastic`

This folder is for non-secret evidence that supports a `stochastic` report.

Allowed evidence, when the current task asks for it:

- small text summaries of command output;
- checksums;
- image tags and digests;
- sanitized screenshots;
- sanitized log snippets;
- non-secret HTTP/TLS status summaries;
- small manifests of files created for handoff.

Never place these here:

- credentials;
- tokens;
- passwords;
- private keys;
- Docker login config;
- `.env` files;
- shell history captures;
- full environment dumps;
- private SSH config;
- student identifiers;
- live service secrets;
- sensitive config payloads;
- raw transcripts that include prompts or values for credentials.

If evidence cannot be captured safely, write a short note in
`docs/ops/stochastic/outbox/current-report.md` explaining what safer capture
method is needed.
