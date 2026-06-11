# Campus IT Email Draft

Subject: Teaching Shiny HTTPS hostname and certificate guidance for deep-server

Dear IT Service Desk,

I am preparing a browser-based R Shiny practical activity for rPVA Practical 1.
It is currently running only as non-student staging on `deep-server`; no
student accounts, student data, or class workspaces are involved yet.

The immediate tested service is rPVA Practical 1. I also teach KPZ314 (Fauna of
Tasmania), which is expected to use an R Shiny GUI for a practical activity on
species distribution models. I would therefore like to align on a reusable
teaching-Shiny hostname and certificate pattern, rather than treating rPVA as a
one-off URL.

Current tested state:

- Host: `deep-server`, currently reachable on the campus route at
  `131.217.90.193`.
- Reverse-DNS lead: `SET-BIO-2621GL2.zoo.utas.edu.au`.
- The rPVA Practical 1 ShinyProxy staging service is behind nginx on HTTPS
  port `443`.
- From inside the University network, `https://131.217.90.193/login` reaches a
  ShinyProxy sign-in page.
- The browser still marks the page as not secure because the gateway currently
  serves a self-signed `deep-server` certificate, not a browser-trusted
  certificate for a class-appropriate hostname.

Could IT please advise the approved hostname, DNS, certificate, renewal, and
nginx/TLS ownership path for this teaching Shiny service?

Specific questions:

1. Should this teaching service use `SET-BIO-2621GL2.zoo.utas.edu.au`, or
   should IT create or nominate a clearer teaching-Shiny hostname?
2. Who owns the DNS record for the approved hostname, and should it target
   `131.217.90.193`?
3. Who should issue and own the browser-trusted TLS certificate for that
   hostname?
4. Should IT place the certificate and key on `deep-server`, or provide an
   approved non-interactive issuance mechanism for the host administrator to
   run?
5. Who owns certificate renewal and expiry monitoring?
6. Should IT own nginx TLS termination, or may the rPVA team make a narrow,
   reversible nginx TLS configuration edit after IT approves the hostname and
   certificate paths?
7. Are there network policy constraints for this teaching route, such as
   campus-only access, VPN requirement, or another approved access model?
8. Can the same hostname pattern or teaching-Shiny platform decision support
   future R Shiny practical activities, including the planned KPZ314 species
   distribution modelling GUI?

The rPVA team is not asking IT to debug the R/Shiny application internals. The
request is specifically for hostname, DNS, certificate, renewal, nginx/TLS
ownership, and access-policy guidance before any student-facing release.

If IT can confirm the preferred path, I will use that written decision to
request a separate, narrowly reviewed implementation and browser-proof step.

Regards,

Barry W. Brook
