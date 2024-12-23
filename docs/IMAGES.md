# Images

> [!NOTE]
> Learn about unprivileged user namespaces [here](USERNS.md).

## Desktop

*`nvidia-open` images are recommended for systems with Nvidia GPUs Turing or newer. These include the new [open kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules) from Nvidia, not Nouveau.*

*`nvidia` images are recommended for systems with Nvidia GPUs Pascal or older. These include the closed kernel modules from Nvidia.*

### Recommended <sup>[why?](RECOMMENDED.md)</sup>
#### Silverblue
| Name                                      | Base      | Nvidia Support         |
|-------------------------------------------|-----------|-------------------------|
| `silverblue-main-hardened`               | Silverblue| No                      |
| `silverblue-nvidia-hardened`             | Silverblue| Yes, closed drivers     |
| `silverblue-nvidia-open-hardened`        | Silverblue| Yes, open drivers       |

### Stable
#### Kinoite
| Name                                      | Base      | Nvidia Support         |
|-------------------------------------------|-----------|-------------------------|
| `kinoite-main-hardened`                  | Kinoite   | No                      |
| `kinoite-nvidia-hardened`                | Kinoite   | Yes, closed drivers     |
| `kinoite-nvidia-open-hardened`           | Kinoite   | Yes, open drivers       |

#### Sericea
| Name                                      | Base      | Nvidia Support         |
|-------------------------------------------|-----------|-------------------------|
| `sericea-main-hardened`                  | Sericea   | No                      |
| `sericea-nvidia-hardened`                | Sericea   | Yes, closed drivers     |
| `sericea-nvidia-open-hardened`           | Sericea   | Yes, open drivers       |

### Beta
> [!NOTE]
> Learn about wayblue [here](https://github.com/wayblueorg/wayblue).

#### Wayfire
| Name                                      | Base                  | Nvidia Support         |
|-------------------------------------------|-----------------------|-------------------------|
| `wayblue-wayfire-main-hardened`          | Wayblue-Wayfire       | No                      |
| `wayblue-wayfire-nvidia-hardened`        | Wayblue-Wayfire       | Yes, closed drivers     |
| `wayblue-wayfire-nvidia-open-hardened`   | Wayblue-Wayfire       | Yes, open drivers       |

#### Hyprland
| Name                                      | Base                  | Nvidia Support         |
|-------------------------------------------|-----------------------|-------------------------|
| `wayblue-hyprland-main-hardened`         | Wayblue-Hyprland      | No                      |
| `wayblue-hyprland-nvidia-hardened`       | Wayblue-Hyprland      | Yes, closed drivers     |
| `wayblue-hyprland-nvidia-open-hardened`  | Wayblue-Hyprland      | Yes, open drivers       |

#### River
| Name                                      | Base                  | Nvidia Support         |
|-------------------------------------------|-----------------------|-------------------------|
| `wayblue-river-main-hardened`            | Wayblue-River         | No                      |
| `wayblue-river-nvidia-hardened`          | Wayblue-River         | Yes, closed drivers     |
| `wayblue-river-nvidia-open-hardened`     | Wayblue-River         | Yes, open drivers       |


#### Sway
| Name                                      | Base                  | Nvidia Support         |
|-------------------------------------------|-----------------------|-------------------------|
| `wayblue-sway-main-hardened`             | Wayblue-Sway          | No                      |
| `wayblue-sway-nvidia-hardened`           | Wayblue-Sway          | Yes, closed drivers     |
| `wayblue-sway-nvidia-open-hardened`      | Wayblue-Sway          | Yes, open drivers       |

## Server
> [!NOTE]
> After you finish setting up your [Fedora CoreOS](https://fedoraproject.org/coreos/) installation, you will need to disable `zincati.service` before rebasing to securecore.

| Name                                      | Base      | Nvidia Support         | ZFS Support |
|-------------------------------------------|-----------|-------------------------|-------------|
| `securecore-main-hardened`               | CoreOS    | No                      | No          |
| `securecore-nvidia-hardened`             | CoreOS    | Yes, closed drivers     | No          |
| `securecore-nvidia-open-hardened`        | CoreOS    | Yes, open drivers       | No          |
| `securecore-zfs-main-hardened`           | CoreOS    | No                      | Yes         |
| `securecore-zfs-nvidia-hardened`         | CoreOS    | Yes, closed drivers     | Yes         |
| `securecore-zfs-nvidia-open-hardened`    | CoreOS    | Yes, open drivers       | Yes         |


### Experimental

#### Cosmic
| Name                                      | Base                  | Nvidia Support         |
|-------------------------------------------|-----------------------|-------------------------|
| `cosmic-main-hardened`          | Cosmic       | No                      |
| `cosmic-nvidia-hardened`        | Cosmic       | Yes, closed drivers     |
| `cosmic-nvidia-open-hardened`   | Cosmic       | Yes, open drivers       |
