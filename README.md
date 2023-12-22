<p align="center">
  <a href="https://github.com/secureblue/secureblue">
    <img src="https://github.com/secureblue/secureblue/assets/129108030/292e0ecc-50b8-4de5-a11a-bfe292489f6c" href="https://github.com/secureblue/secureblue" width=180 />
  </a>
</p>

<h1 align="center">secureblue</h1>


[![secureblue](https://github.com/secureblue/secureblue/actions/workflows/build.yml/badge.svg)](https://github.com/secureblue/secureblue/actions/workflows/build.yml)

This repo takes the [uBlue](https://universal-blue.org/) starting point and selectively applies hardening with the following goals:

- Increase defenses against the exploitation of both known and unknown vulnerabilities.
- Avoid sacrificing usability for most use cases where possible

The following are not in scope for this project:
- Anything related to increasing "privacy", especially when at odds with improving security
- Anything related to "degoogling" chromium. For example, we will not be replacing chromium with Brave or ungoogled-chromium.

## What

Hardening applied:

- Setting numerous hardened sysctl values (Inspired by but not the same as Kicksecure's)
- Disabling coredumps in limits.conf
- Disabling all ports and services for firewalld
- Adds per-network MAC randomization
- Blacklisting numerous unused kernel modules to reduce attack surface
- Require a password for sudo every time it's called
- Disable passwordless sudo for rpm-ostree
- Brute force protection by locking user accounts for 24 hours after 50 failed login attempts, hardened password encryption and password quality suggestions
- Installing chkrootkit
- (Non-userns variants) Disabling unprivileged user namespaces
- (Non-userns variants) Replacing bubblewrap with bubblewrap-suid so flatpak can be used without unprivileged user namespaces
- Enabling only the [flathub-verified](https://flathub.org/apps/collection/verified/1) remote by default
- Sets numerous hardening kernel parameters (Inspired by [Madaidan's Hardening Guide](https://madaidans-insecurities.github.io/guides/linux-hardening.html))
- Installs and enables [hardened_malloc](https://github.com/GrapheneOS/hardened_malloc) globally, including for flatpaks
- Installing Chromium instead of Firefox in the base image ([Why chromium?](https://grapheneos.org/usage#web-browsing)) ([Why not flatpak chromium?](https://forum.vivaldi.net/post/669805))
- Including a hardened chromium config that disables JIT javascript ([why?](https://microsoftedge.github.io/edgevr/posts/Super-Duper-Secure-Mode/#is-jit-worth-it))
- Pushing upstream fedora to harden the build for all fedora users, including secureblue users ([for example, by enabling CFI](https://bugzilla.redhat.com/show_bug.cgi?id=2252874))

## Why

Fedora is one of the few distributions that ships with selinux and associated tooling built-in and enabled by default. This makes it advantageous as a starting point for building a hardened system. However, out of the box it's lacking hardening in numerous other areas. This project's goal is to improve on that significantly.


For more info on uBlue, check out the [uBlue homepage](https://universal-blue.org/) and the [main uBlue repo](https://github.com/ublue-os/main/)

## Installation

> **Warning**
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) and should not be used in production, try it in a VM for a while!


### Available Images

#### Without User Namespaces

##### desktop
- kinoite-main-hardened
- kinoite-nvidia-hardened
- bluefin-main-hardened
- bluefin-nvidia-hardened
- lazurite-main-hardened
- lazurite-nvidia-hardened
- silverblue-main-hardened
- silverblue-nvidia-hardened
- sericea-main-hardened
- sericea-nvidia-hardened

##### laptop
- kinoite-main-laptop-hardened
- kinoite-nvidia-laptop-hardened
- bluefin-main-laptop-hardened
- bluefin-nvidia-laptop-hardened
- lazurite-main-laptop-hardened
- lazurite-nvidia-laptop-hardened
- silverblue-main-laptop-hardened
- silverblue-nvidia-laptop-hardened
- sericea-main-laptop-hardened
- sericea-nvidia-laptop-hardened

##### server
- server-main-hardened
- server-nvidia-hardened

#### With User Namespaces

##### desktop
- kinoite-main-userns-hardened
- kinoite-nvidia-userns-hardened
- bluefin-main-userns-hardened
- bluefin-nvidia-userns-hardened
- lazurite-main-userns-hardened
- lazurite-nvidia-userns-hardened
- silverblue-main-userns-hardened
- silverblue-nvidia-userns-hardened
- sericea-main-userns-hardened
- sericea-nvidia-userns-hardened

##### laptop
- kinoite-main-laptop-userns-hardened
- kinoite-nvidia-laptop-userns-hardened
- bluefin-main-laptop-userns-hardened
- bluefin-nvidia-laptop-userns-hardened
- lazurite-main-laptop-userns-hardened
- lazurite-nvidia-laptop-userns-hardened
- silverblue-main-laptop-userns-hardened
- silverblue-nvidia-laptop-userns-hardened
- sericea-main-laptop-userns-hardened
- sericea-nvidia-laptop-userns-hardened

##### server
- server-main-userns-hardened
- server-nvidia-userns-hardened


### Rebasing

To rebase an existing Silverblue/Kinoite installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/secureblue/$IMAGE_NAME:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/secureblue/$IMAGE_NAME:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```
  
### Post-install

After installation, [yafti](https://github.com/ublue-os/yafti) will open. Make sure to follow the steps listed carefully and read the directions closely.

#### Kargs
To append kernel boot parameters that apply additional hardening (reboot required):

```
just set-kargs-hardening 
```

#### Nvidia
If you are using an nvidia image, run this after installation:

```
rpm-ostree kargs \
    --append=rd.driver.blacklist=nouveau \
    --append=modprobe.blacklist=nouveau \
    --append=nvidia-drm.modeset=1
```

## Contributing

Follow the [contributing documentation](CONTRIBUTING.md#contributing), and make sure to respect the [CoC](CODE_OF_CONDUCT.md).

### Development

For local Development [building locally](CONTRIBUTING.md#building-locally) is the recommended approach.
