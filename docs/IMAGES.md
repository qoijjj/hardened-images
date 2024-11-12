# Images

> [!NOTE]
> Learn about unprivileged user namespaces [here](USERNS.md).

## Desktop

*`nvidia-open` images are recommended for systems with Nvidia GPUs Turing or newer. These include the new [open kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules) from Nvidia, not Nouveau.*

*`nvidia` images are recommended for systems with Nvidia GPUs Pascal or older. These include the closed kernel modules from Nvidia.*

### Recommended <sup>[why?](RECOMMENDED.md)</sup>
#### Silverblue
| Name                                      | Base      | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------|-------------------------|------------------------------|
| `silverblue-main-hardened`               | Silverblue| No                      | No                           |
| `silverblue-nvidia-hardened`             | Silverblue| Yes, closed drivers     | No                           |
| `silverblue-nvidia-open-hardened`        | Silverblue| Yes, open drivers       | No                           |
| `silverblue-main-userns-hardened`        | Silverblue| No                      | Yes                          |
| `silverblue-nvidia-userns-hardened`      | Silverblue| Yes, closed drivers     | Yes                          |
| `silverblue-nvidia-open-userns-hardened` | Silverblue| Yes, open drivers       | Yes                          |

### Stable
#### Kinoite
| Name                                      | Base      | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------|-------------------------|------------------------------|
| `kinoite-main-hardened`                  | Kinoite   | No                      | No                           |
| `kinoite-nvidia-hardened`                | Kinoite   | Yes, closed drivers     | No                           |
| `kinoite-nvidia-open-hardened`           | Kinoite   | Yes, open drivers       | No                           |
| `kinoite-main-userns-hardened`           | Kinoite   | No                      | Yes                          |
| `kinoite-nvidia-userns-hardened`         | Kinoite   | Yes, closed drivers     | Yes                          |
| `kinoite-nvidia-open-userns-hardened`    | Kinoite   | Yes, open drivers       | Yes                          |

#### Sericea
| Name                                      | Base      | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------|-------------------------|------------------------------|
| `sericea-main-hardened`                  | Sericea   | No                      | No                           |
| `sericea-nvidia-hardened`                | Sericea   | Yes, closed drivers     | No                           |
| `sericea-nvidia-open-hardened`           | Sericea   | Yes, open drivers       | No                           |
| `sericea-main-userns-hardened`           | Sericea   | No                      | Yes                          |
| `sericea-nvidia-userns-hardened`         | Sericea   | Yes, closed drivers     | Yes                          |
| `sericea-nvidia-open-userns-hardened`    | Sericea   | Yes, open drivers       | Yes                          |

### Beta
> [!NOTE]
> Learn about wayblue [here](https://github.com/wayblueorg/wayblue).

#### Wayfire
| Name                                      | Base                  | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------------------|-------------------------|------------------------------|
| `wayblue-wayfire-main-hardened`          | Wayblue-Wayfire       | No                      | No                           |
| `wayblue-wayfire-nvidia-hardened`        | Wayblue-Wayfire       | Yes, closed drivers     | No                           |
| `wayblue-wayfire-nvidia-open-hardened`   | Wayblue-Wayfire       | Yes, open drivers       | No                           |
| `wayblue-wayfire-main-userns-hardened`   | Wayblue-Wayfire       | No                      | Yes                          |
| `wayblue-wayfire-nvidia-userns-hardened` | Wayblue-Wayfire       | Yes, closed drivers     | Yes                          |
| `wayblue-wayfire-nvidia-open-userns-hardened` | Wayblue-Wayfire | Yes, open drivers       | Yes                          |

#### Hyprland
| Name                                      | Base                  | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------------------|-------------------------|------------------------------|
| `wayblue-hyprland-main-hardened`         | Wayblue-Hyprland      | No                      | No                           |
| `wayblue-hyprland-nvidia-hardened`       | Wayblue-Hyprland      | Yes, closed drivers     | No                           |
| `wayblue-hyprland-nvidia-open-hardened`  | Wayblue-Hyprland      | Yes, open drivers       | No                           |
| `wayblue-hyprland-main-userns-hardened`  | Wayblue-Hyprland      | No                      | Yes                          |
| `wayblue-hyprland-nvidia-userns-hardened`| Wayblue-Hyprland      | Yes, closed drivers     | Yes                          |
| `wayblue-hyprland-nvidia-open-userns-hardened` | Wayblue-Hyprland | Yes, open drivers       | Yes                          |

#### River
| Name                                      | Base                  | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------------------|-------------------------|------------------------------|
| `wayblue-river-main-hardened`            | Wayblue-River         | No                      | No                           |
| `wayblue-river-nvidia-hardened`          | Wayblue-River         | Yes, closed drivers     | No                           |
| `wayblue-river-nvidia-open-hardened`     | Wayblue-River         | Yes, open drivers       | No                           |
| `wayblue-river-main-userns-hardened`     | Wayblue-River         | No                      | Yes                          |
| `wayblue-river-nvidia-userns-hardened`   | Wayblue-River         | Yes, closed drivers     | Yes                          |
| `wayblue-river-nvidia-open-userns-hardened` | Wayblue-River     | Yes, open drivers       | Yes                          |


#### Sway
| Name                                      | Base                  | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------------------|-------------------------|------------------------------|
| `wayblue-sway-main-hardened`             | Wayblue-Sway          | No                      | No                           |
| `wayblue-sway-nvidia-hardened`           | Wayblue-Sway          | Yes, closed drivers     | No                           |
| `wayblue-sway-nvidia-open-hardened`      | Wayblue-Sway          | Yes, open drivers       | No                           |
| `wayblue-sway-main-userns-hardened`      | Wayblue-Sway          | No                      | Yes                          |
| `wayblue-sway-nvidia-userns-hardened`    | Wayblue-Sway          | Yes, closed drivers     | Yes                          |
| `wayblue-sway-nvidia-open-userns-hardened` | Wayblue-Sway       | Yes, open drivers       | Yes                          |

## Server
> [!NOTE]
> After you finish setting up your [Fedora CoreOS](https://fedoraproject.org/coreos/) installation, you will need to disable `zincati.service` before rebasing to securecore.

| Name                                      | Base      | Nvidia Support         | ZFS Support | Unpriv. Userns |
|-------------------------------------------|-----------|-------------------------|-------------|------------------------------|
| `securecore-main-hardened`               | CoreOS    | No                      | No          | No                           |
| `securecore-nvidia-hardened`             | CoreOS    | Yes, closed drivers     | No          | No                           |
| `securecore-nvidia-open-hardened`        | CoreOS    | Yes, open drivers       | No          | No                           |
| `securecore-main-userns-hardened`        | CoreOS    | No                      | No          | Yes                          |
| `securecore-nvidia-userns-hardened`      | CoreOS    | Yes, closed drivers     | No          | Yes                          |
| `securecore-nvidia-open-userns-hardened` | CoreOS    | Yes, open drivers       | No          | Yes                          |
| `securecore-zfs-main-hardened`           | CoreOS    | No                      | Yes         | No                           |
| `securecore-zfs-nvidia-hardened`         | CoreOS    | Yes, closed drivers     | Yes         | No                           |
| `securecore-zfs-nvidia-open-hardened`    | CoreOS    | Yes, open drivers       | Yes         | No                           |
| `securecore-zfs-main-userns-hardened`    | CoreOS    | No                      | Yes         | Yes                          |
| `securecore-zfs-nvidia-userns-hardened`  | CoreOS    | Yes, closed drivers     | Yes         | Yes                          |
| `securecore-zfs-nvidia-open-userns-hardened` | CoreOS  | Yes, open drivers       | Yes         | Yes                          |


### Experimental

#### Cosmic
| Name                                      | Base                  | Nvidia Support         | Unpriv. Userns |
|-------------------------------------------|-----------------------|-------------------------|------------------------------|
| `cosmic-main-hardened`          | Cosmic       | No                      | No                           |
| `cosmic-nvidia-hardened`        | Cosmic       | Yes, closed drivers     | No                           |
| `cosmic-nvidia-open-hardened`   | Cosmic       | Yes, open drivers       | No                           |
| `cosmic-main-userns-hardened`   | Cosmic       | No                      | Yes                          |
| `cosmic-nvidia-userns-hardened` | Cosmic       | Yes, closed drivers     | Yes                          |
| `cosmic-nvidia-open-userns-hardened` | Cosmic | Yes, open drivers       | Yes                          |
