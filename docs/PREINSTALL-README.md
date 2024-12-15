# secureblue

The recommended method to install secureblue is to rebase from an upstream silverblue/kinoite installation. Before rebasing and during the installation, the following checks are recommended.

## Preinstall guide

> [!TIP]
> The cross-platform Fedora Media Writer is the *official, tested and supported* method for the creation of bootable media, instructions (alongside a word on alternative methods) are available [here](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/).

> [!CAUTION]
> The Fedora 41 ISO contains a bugged version of rpm-ostree, causing issues. As such, it's required that you use a daily-built ISO to rebase from. This has no effect on secureblue or the resulting installation. Daily ISOs are available from Fedora [here](https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Silverblue/x86_64/iso/).

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
