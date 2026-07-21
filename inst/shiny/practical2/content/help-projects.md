## Browser recovery

The app keeps a validated project snapshot **autosaved in this browser**. This
recovery copy belongs to the current browser and web origin. A copy saved under
one host is not automatically available under another host, even on the same
computer.

Resume is always explicit. The app first lists available project metadata; it
does not restore project contents until you choose a project and select
**Resume selected project**.

## Portable projects

A portable project is the supported way to move work to another browser or
host. Select **Download portable project**, keep the ZIP file, then import it in
the other app. The status says **download requested** because the app cannot
confirm where your browser saved the file.

Material changes can make the last portable copy out of date. Request a new
download before changing browser or host, and before leaving work you need to
retain.

Imported and restored content is treated as untrusted data. The live project
changes only after its exact type, schema, identifiers, metadata, and content
fingerprint have passed validation.
