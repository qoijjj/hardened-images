# secureblue

After rebasing to secureblue, the following steps are recommended.

## GRUB
### Set a password

Setting a GRUB password helps protect the device from physical tampering and mitigates various attack vectors, such as booting from malicious media devices and changing boot or kernel parameters.

To set a GRUB password, use the following command. By default, the password will be required when modifying boot entries, but not when booting existing entries.

```sudo grub2-setpassword```

GRUB will prompt for a username and password. The default username is root.

If you wish to password-protect booting existing entries, you can add the `grub_users root` entry in the specific configuration file located in the `/boot/loader/entries` directory.

### Remove duplicate boot entries
If you are on an UEFI system, the fix for [this known problem](https://discussion.fedoraproject.org/t/why-does-grub2-present-twice-double-menuentry-for-each-ostree-entry/) is running this command.

```
sudo grub2-switch-to-blscfg
```

Note that [the issuetracker](https://github.com/fedora-silverblue/issue-tracker/issues/120) is still open, and running this command may [break GRUB on BIOS systems](https://discussion.fedoraproject.org/t/boot-entries-gone-after-upgrade/8026/6)!

## Create a separate wheel account for admin purposes

Creating a dedicated wheel user and removing wheel from your primary user helps prevent certain attack vectors:

- https://www.kicksecure.com/wiki/Dev/Strong_Linux_User_Account_Isolation#LD_PRELOAD
- https://www.kicksecure.com/wiki/Root#Prevent_Malware_from_Sniffing_the_Root_Password

1. ```adduser admin```
2. ```usermod -aG wheel admin```
3. ```gpasswd -d {your username here} wheel```
4. ```reboot```

When not in the wheel group, a user can be added to a dedicated group, otherwise certain actions are blocked:

- use virtual machines: `libvirt`
- use `adb` and `fastboot`: `plugdev`
- use systemwide flatpaks: `flatpak`

Be aware that granting these permissions will increase attack surface, so keep them as minimal as possible. Some actions don't have an associated group yet, you can create your own rules and groups to fix this.

**Example**: Use LUKS encrypted backup drives

1. `sudo groupadd diskadmin`
2. `sudo usermod -aG diskadmin {your username here}`
3. execute this command (*explanation below*)

```
cat >> /etc/polkit-1/rules.d/80-udisks2.rules <<EOF
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.udisks2.encrypted-unlock-system" || action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
        subject.active == true && subject.local == true &&
        subject.isInGroup("diskadmin"))
        {
        return polkit.Result.YES;
    }
});
EOF
```

The custom rule allows the group`diskadmin` to do the actions for unlocking and mounting these drives. Note the requirement on `active` and `local`, and the exactly specified actions.

## Chromium
### Extension

1. Go to [uBlock Origin Lite](https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh?pli=1) ([Why Lite?](https://developer.chrome.com/docs/extensions/develop/migrate/improve-security))
2. Install it
3. In the extension's settings, make sure all of the lists under Default and Miscellaneous are checked (and at your preference, lists in the Annoyances section or country-specific lists)

### Settings
1. Go to `chrome://settings/security`
2. Scroll to "Always use secure connections" and enable it

