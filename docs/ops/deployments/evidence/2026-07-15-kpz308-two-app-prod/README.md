# KPZ308 Two-App Production Evidence

Date: 2026-07-15
Environment: `ecology-r1.its.utas.edu.au`
Result: passed and closed to Staff-only P2

This directory preserves the evidence for the production concurrency and
routing gate. Staff testing completed the full workflows while Practical 2 was
temporarily visible to both Staff and KPZ308. Empirical student access remains
a separate gate.

## Image identity

| App | ShinyProxy ID | OCI revision | Immutable image | Production-host `.Id` and registry digest |
| --- | --- | --- | --- | --- |
| Practical 1 | `kpz308-rpva-practical` | `02b09aeed4f033ac8a68e3e3c1927f878b3242c9` | `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0` | `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b` |
| Practical 2 | `kpz308-rpva-practical2` | `8aada69b0ac35ee1994e86e5199b38047fdd3efe` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260714-8aada69b0ac3` | `sha256:e7d997f0ce52b22c30747a3b83cbf771e4124e5065010a9212479a53ffc96721` |

The production `RepoDigests` matched the dev-accepted registry manifests and
the OCI revisions matched the source commits.

## Bundle contents

- `prod-config-diff.txt`: redacted production configuration change and rollback
  metadata.
- `prod-server-snapshot.txt`: accepted health, container, resource, workspace,
  and proxy-event output with usernames redacted.
- `browser-result.json`: machine-readable concurrent Playwright result.
- `browser/`: production launcher and app screenshots, including a mobile P2
  evidence view.
- `exports/`: production-downloaded CSV and Markdown evidence from both apps.
- `validation.txt`: row, missing-value, interpretation, image, and browser
  checks.
- `closeout.txt`: anonymous student gate, one-line access-group closeout,
  restart, and final Staff smoke record.
- `closeout/`: final Staff launcher/P1/P2 screenshots and machine-readable
  result after P2 returned to Staff-only.
- `checksums.sha256`: integrity manifest for every other bundle file.

## Acceptance summary

- Production began healthy with the older P1 image and no P2 spec.
- Both accepted images were pulled and verified before configuration changed.
- A timestamped permission- and SELinux-preserving backup was created.
- The reviewed diff changed only the P1 image line and added one P2 spec with
  Staff plus KPZ308 access and its own workspace root.
- ShinyProxy restarted and actuator health returned `UP` on attempt 3.
- Real UTAS SAML and Duo authentication completed.
- Both launcher tiles and both app routes were visible to a Staff account.
- P1 completed two comparison rows; P2 completed five management and four
  sensitivity rows; all exports validated.
- Both exact app containers were simultaneously healthy and linked to the
  browser frame proxy IDs.
- ShinyProxy and both app containers remained within their memory limits.
- No browser console warning/error or page exception occurred.

## Canary closeout

- One current KPZ308 student confirmed that both canary tiles were visible and
  both apps opened, including the P2 Woodhen surface.
- The tester is recorded by role only; no student identifier is retained.
- A second timestamped backup was created.
- Exactly one `KPZ308` access-group line was removed from P2.
- P1 retained Staff plus KPZ308; P2 retained Staff only.
- ShinyProxy restarted and returned `UP` on attempt 3.
- Final Staff smoke confirmed both launcher tiles and both app routes remained
  available with no browser console or page errors.

## Monitoring limitation

The normal UTAS infrastructure contact was on leave, so independent host-level
monitoring feedback was unavailable for this interval. The captured actuator,
container health, CPU, memory, network, and process evidence passed. The
approved plan states that unavailable monitoring feedback does not invalidate
functional proof.

## Observed warning

Compose printed `IPv4 forwarding is disabled. Networking will not work.` while
starting the rootless service. Both app containers subsequently activated,
served their complete browser workflows, and exported evidence concurrently.
The warning did not describe the observed runtime result and is retained as a
known environment message.

## Redaction

Staff usernames are replaced with `<staff-user-N>`. No passwords, cookies,
tokens, SAML assertions, or student identifiers are included.
