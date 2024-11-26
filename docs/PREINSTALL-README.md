# secureblue

The recommended method to install secureblue is to rebase from an upstream silverblue/kinoite installation. Before rebasing and during the installation, the following checks are recommended.

## Preinstall guide

> [!TIP]
> The cross-platform Fedora Media Writer is the *official, tested and supported* method for the creation of bootable media, instructions (alongside a word on alternative methods) are available [here](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/).

### Fedora Installation
- Select the option to encrypt the drive you're installing to.
- Use a [strong password](https://security.harvard.edu/use-strong-passwords) when prompted.
- Leave the root account disabled.
- Select wheel group membership for your user

### BIOS Hardening
- Ensure secureboot is enabled.
- Ensure your BIOS is up to date by checking its manufacturer's website.
- Disable booting from USB (some manufacturers allow firmware changes from live systems).
- Set a BIOS password to prevent tampering.
