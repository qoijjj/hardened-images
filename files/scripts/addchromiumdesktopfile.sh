
#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

sed -i 's/org.mozilla.firefox/hardened-chromium/' /usr/share/wayfire/wf-shell.ini 
