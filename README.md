# Crema — a KDE Plasma 6 theme

A warm espresso dark theme for KDE Plasma, derived from the **CREMA** color
scheme used across the CafeNeurotico projects.

| Role | Color | |
|------|-------|--|
| Background | `#2C1E16` | dark espresso |
| Menu / panel | `#432818` | roasted brown |
| Accent | `#D4A373` | caramel crema |
| Text | `#FFE6A7` | warm cream |
| Border | `#8B5A2B` | walnut |

## What this is

A **portable, user-level** KDE theme. Everything installs into your home
(`~/.local/share`, `~/.config`) — **no root, no system files touched, fully
reversible**. Copy this folder to any machine and run `./install.sh`.

**Components** (each is an installer toggle — its `id` in parentheses)

| Piece | What it does | id |
|-------|--------------|----|
| Color scheme | Crema palette across Plasma + Qt/KDE apps | `colorscheme` |
| Global Theme | bundles Plasma style + splash as one selectable theme | `globaltheme` |
| Plasma desktop theme | pinned Crema palette (Breeze shapes recolored) | `desktoptheme` |
| Konsole / Yakuake | terminal scheme + profile, **set as the default** | `konsole` |
| Editor theme | Kate/KWrite/KDevelop syntax colors | `editor` |
| OBS Studio | Crema `.ovt` variant theme (OBS 30+) | `obs` |
| Bundled fonts | install the Poppins family | `fonts` |
| UI font (opt-in) | set Poppins as the interface font, titlebar SemiBold | `fontapply` |
| GTK apps | GTK4/libadwaita colors (+ Flatpak read access); GTK3 is automatic | `gtk` |
| Chromium (opt-in) | stage a Crema theme for Chrome/Brave (load unpacked) | `browser_chromium` |
| Firefox (opt-in) | apply a Crema `userChrome.css` to your profiles | `browser_firefox` |
| App launcher | add a clickable **CREMA Desktop Theme Installer** to the app menu + desktop | `launcher` |

Window decoration/style stays **Breeze** recolored (rounded in Plasma 6). Notes:
**does not change your wallpaper**; a fully custom Qt widget style would need the
Kvantum engine (not portable on atomic distros). Login screen is separate (below).

## Install

The easiest way is the **visual installer** — an espresso-themed checklist
(rendered with `yad`, styled by `lib/installer.css`) to pick components:

```bash
./install.sh --gui
```

After the first run, the `launcher` component adds a clickable **CREMA Desktop Theme Installer**
to your application menu and Desktop, so you can reopen the GUI without a terminal
(first Desktop click: choose *Trust & run*).

Or the CLI:

```bash
./install.sh                 # install the default set (nothing applied yet)
./install.sh --apply         # install defaults and switch to Crema now
./install.sh --all --apply   # everything (incl. font, browsers) + apply
./install.sh --only=gtk,konsole   # just these components
./install.sh --font          # add the Poppins UI font to the default set
./install.sh --list          # list component ids
```

You can also apply manually: **System Settings → Colors & Themes → Global Theme → Crema**.

## Browsers

Browser theming is uneven by nature — here's the honest state per browser:

- **Chrome / Brave / Chromium** — the `browser_chromium` component sets Chromium's
  built-in **"Orange" dark theme** (a warm palette that fits Crema) by writing the
  `Preferences` theme block. Works for **Flatpak and native**, no managed policy
  needed. **Close the browser first** — Chromium rewrites `Preferences` on exit, so
  the component skips any running browser and tells you to close it and re-run.
  (Note: Chrome PWAs count as "Chrome running".)
- **Brave** — the Orange theme applies here too; alternatively *Settings → Appearance
  → Qt* makes Brave follow the Crema color scheme.
- **Firefox** — themes are installed **add-ons**, not a settable value, so the
  installer can't set one for you the way it sets Chrome's Orange. Use a color-theme
  add-on from AMO (e.g. *Blue Coffee*); the bundled `userChrome.css` only lightly
  recolors the chrome.

**Alternative — native real-time theming (Omarchy method).** For *native* (non-Flatpak)
Chromium/Chrome/Brave/Edge, `browsers/apply-chrome-policy.sh` (sudo) writes a
`BrowserThemeColor` managed policy + `--refresh-platform-policy` for instant,
policy-driven theming. Flatpak browsers can't read managed policies
([flatpak#4709](https://github.com/flatpak/flatpak/issues/4709)), which is why the
Preferences method above is the default. A custom-caramel unpacked theme
(`browsers/chromium/manifest.json`, load via *Extensions → Developer mode → Load
unpacked*) is also available if you prefer Crema's own colors over Orange.

## Login screen (SDDM) — applied separately

The login screen lives in a **system** directory, so it's kept out of the
user-level `install.sh` and needs `sudo`. It's a low-risk **background reskin**
of the already-working `01-breeze-fedora` greeter (Bazzite serves the greeter
from a container image, so a from-scratch QML theme can't be shipped safely) —
it changes only the login *background*, never the greeter logic, so it cannot
break login.

```bash
sudo ./sddm/apply-sddm.sh            # apply the Crema login background
sudo ./sddm/apply-sddm.sh --revert   # restore your previous background
```

It backs up your current `theme.conf.user` first. See it by logging out or
rebooting. The background art (`sddm/crema-login.jpg`, 3440×1440) is espresso
gradient + a faint coffee-cup watermark; regenerate at another size with any
image tool if needed.

## Reset to system default

The quickest way back: the visual installer's **Reset to Default** button (or
`./install.sh --reset`). It switches your desktop back to the KDE default
(**Breeze**) and then removes every file Crema installed — all user-level, no
password, and your panel layout is left untouched.

```bash
./install.sh --reset                 # back to Breeze + remove everything Crema
```

## Uninstall

To only remove files (without switching your active theme):

```bash
./install.sh --uninstall             # removes the default set
./install.sh --uninstall --all       # removes every component
./install.sh --uninstall --only=gtk  # just one
sudo ./sddm/apply-sddm.sh --revert   # (if you applied the login screen)
```

Uninstall restores files it backed up (e.g. `kdeglobals`, `gtk-4.0/gtk.css` from
their `*.pre-crema.bak`). Then pick another Global Theme in System Settings.

The login screen (SDDM) is the one thing that lives outside your home folder, so
it reverts separately with `sudo ./sddm/apply-sddm.sh --revert`. Neither
`--reset` nor the GUI button ever touches it.

## Layout

```
lib/components.sh                                 # per-component install/uninstall (shared)
lib/installer.css                                 # Crema styling for the yad installer
icons/crema-installer.png                         # installer / launcher icon
install.sh                                        # CLI front-end
crema-installer.sh                                # visual (yad) front-end
color-schemes/Crema.colors                        # palette mapped to KDE color roles
look-and-feel/com.cafeneurotico.crema.desktop/    # Global Theme package (+ splash/)
desktoptheme/Crema/                               # Plasma desktop theme (pinned colors)
konsole/Crema.{colorscheme,profile}              # terminal theme
editor/crema.theme                                # KSyntaxHighlighting theme
obs/Crema.ovt                                      # OBS Studio variant theme
gtk/crema.css                                     # GTK4/libadwaita named-color overrides
browsers/chrome-theme.json                        # Chrome/Brave built-in "Orange" theme block
browsers/set-chrome-theme.py                      # merges/resets the Preferences theme block
browsers/chromium/manifest.json                   # optional custom-caramel theme (load unpacked)
browsers/firefox/userChrome.css                   # Firefox chrome recolor
browsers/apply-chrome-policy.sh                   # native Chrome real-time theming (sudo)
sddm/{crema-login.jpg,theme.conf.user,apply-sddm.sh}  # login screen (sudo, separate)
fonts/Poppins-*.ttf                               # bundled interface font
```

## Roadmap

- **Phase 1–2 — done:** color scheme, Global Theme, Plasma desktop theme, splash,
  Konsole, editor theme.
- **SDDM login — done:** background reskin, applied separately with `sudo`.
- **Phase 3 — done:** component-based installer with an espresso-themed **visual
  (yad) front-end** + clickable menu/desktop launcher; Konsole/Yakuake set as
  default; **GTK4/libadwaita** colors (+ Flatpak access); **Chromium & Firefox**
  browser theming; **OBS Studio** theme; native-Chrome real-time policy theming.
- **Later (optional):** a Kvantum application style — needs the Kvantum engine,
  not portable on atomic distros.
