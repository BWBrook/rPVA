# Plan

## Phase 1: Orient And Guard

1. Read Goal 028 and the Goal 025-027 reports.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal028-campus-it-tls-request-pack` and
   the base is `2843b0d`.
4. Stop if unexpected dirty state exists outside the Goal 028 packet.

## Phase 2: Extract The Technical Ask

1. Summarize the immediate rPVA state:
   - non-student ShinyProxy staging exists on `deep-server`;
   - current raw-IP/tailnet routes are not student-suitable;
   - campus route reaches login from Barry's campus browser;
   - TLS trust blocks classroom release.
2. Summarize Goal 027's blocker:
   - no approved class hostname;
   - no trusted certificate path;
   - `SET-BIO-2621GL2.zoo.utas.edu.au` is a lead to assess, not an approved
     teaching URL.
3. Incorporate Barry's KPZ314 note as a future shared teaching-Shiny
   requirement without reading or implementing KPZ314 materials.

## Phase 3: Draft Barry's Message

1. Create `campus-it-email-draft.md`.
2. Use concise, collegial language suitable for a university IT ticket/email.
3. Explain the immediate teaching need and the future reusable Shiny-teaching
   angle.
4. Ask for specific answers rather than broad help:
   - approved hostname or hostname pattern;
   - DNS owner and target;
   - certificate issuance mechanism;
   - renewal owner;
   - whether IT supplies cert/key files or an approved issuance workflow;
   - permission for a narrow nginx TLS edit on `deep-server`.
5. Avoid credential values, private keys, and student data.

## Phase 4: Write Technical Appendix

1. Create `campus-it-tls-request-pack.md`.
2. Include current host/IP/name/certificate facts from Goal 027.
3. Include exactly what IT must decide.
4. Include what a later implementation goal would do after approval.
5. Include what remains out of scope until later student-release gates.
6. Include current safety posture and rollback note.

## Phase 5: Narrow README Pointer

1. Update `docs/teaching/shiny/README.md` only to point to the Goal 028
   coordination pack.
2. Keep detailed IT content in the Goal 028 files.

## Phase 6: Validate And Report

1. Run:
   - `git diff --check`;
   - `Rscript -e 'renv::status(sources = FALSE)'`;
   - marker scan;
   - secret/private-key-pattern scan.
2. Manually review changed text for secrets/private keys.
3. Report changed files, validation, and final recommendation.

## Recommendation Bias

Keep the request short enough that Barry can actually send it. Put operational
detail in the appendix. Frame rPVA as the immediate tested service and KPZ314
as a reason to prefer a reusable teaching-Shiny hostname/certificate pattern.
