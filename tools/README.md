# tools/

*(Español: [README.es.md](README.es.md))*

Two scripts. `ssb_parche_uwp.py` prepares the UWP target and generates the tiles from your own images; `ssb_empaquetar.ps1` packages with MSBuild and signs with your certificate.

Every path is a parameter and the certificate thumbprint is one too: there is no value in here
pointing at the machine these were written on, and no thumbprint baked in.

`-Version` has to go up on every cycle. The console will not replace an installed package with
another one carrying the same version, and the failure looks like the new build is broken.
