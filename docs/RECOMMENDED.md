> [!NOTE]
> This is a relative recommendation between the desktop environments available on secureblue. GNOME has some extra security niceties like the ones listed below. It however does not solve any of the fundamental issues with desktop linux security.

GNOME is the only desktop that secures privileged wayland protocols like screencopy. This means that on non-GNOME systems, applications can access screen content of the entire desktop. This implicitly includes the content of other applications. It's primarily for this reason that GNOME images are recommended. KDE has [plans](https://invent.kde.org/plasma/xdg-desktop-portal-kde/-/issues/7) to fix this.

GNOME also provides [thumbnailer sandboxing](https://gitlab.gnome.org/GNOME/gnome-desktop/-/issues/213) in Gnome Files, which mitigates attacks [via thumbnailers](https://scarybeastsecurity.blogspot.com/2016/11/0day-exploit-compromising-linux-desktop.html).
