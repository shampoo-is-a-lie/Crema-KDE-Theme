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

**Components**

| Piece | What it does | Installs to |
|-------|--------------|-------------|
| Color scheme | Crema palette across Plasma + Breeze apps | `color-schemes/Crema.colors` |
| Global Theme | bundles the below as one selectable theme | `plasma/look-and-feel/com.cafeneurotico.crema.desktop/` |
| Plasma desktop theme | pinned Crema palette (Breeze shapes recolored) | `plasma/desktoptheme/Crema/` |
| Window style/deco | built-in **Breeze** recolored (rounded in Plasma 6) | — |
| Splash screen | espresso boot splash with a coffee-cup mark | inside the Global Theme |
| Konsole | terminal color scheme + profile | `konsole/Crema.*` |
| Editor theme | Kate/KWrite/KDevelop syntax colors | `org.kde.syntax-highlighting/themes/crema.theme` |
| Font (optional) | **Poppins**, titlebar SemiBold | `fonts/Crema/` + `--font` |

Notes: **does not change your wallpaper**; the widget style stays Breeze
(a fully custom Qt style would need the Kvantum engine, which can't be shipped
portably and would require system layering on atomic distros).

## Install

```bash
./install.sh            # install files only (nothing changes yet)
./install.sh --apply    # install and switch to Crema now
./install.sh --apply --font   # also set Poppins as the interface font
```

Or apply manually after installing: **System Settings → Colors & Themes →
Global Theme → Crema**. The color scheme alone is also available under
**Colors & Themes → Colors → Crema**.

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

## Uninstall

```bash
./install.sh --uninstall             # removes the user-level pieces
sudo ./sddm/apply-sddm.sh --revert   # (if you applied the login screen)
```

Then pick another Global Theme in System Settings to switch away. If you used
`--font`, your previous `kdeglobals` is saved at
`~/.config/kdeglobals.crema-fontbackup`.

## Layout

```
color-schemes/Crema.colors                        # palette mapped to KDE color roles
look-and-feel/com.cafeneurotico.crema.desktop/    # Global Theme package (+ splash/)
desktoptheme/Crema/                               # Plasma desktop theme (pinned colors)
konsole/Crema.{colorscheme,profile}              # terminal theme
editor/crema.theme                                # KSyntaxHighlighting theme
sddm/{crema-login.jpg,theme.conf.user,apply-sddm.sh}  # login screen (sudo, separate)
fonts/Poppins-*.ttf                               # bundled interface font
install.sh                                        # portable installer (user-level)
```

## Roadmap

- **Phase 1 — done:** color scheme + Global Theme (Breeze recolored) + installer.
- **Phase 2 — done:** Plasma desktop theme (pinned Crema palette; uses Breeze's
  shapes recolored, so popup shadows render correctly), Konsole scheme, splash
  screen, and editor syntax theme.
- **SDDM login — done:** Crema background reskin of the breeze greeter, applied
  separately with `sudo` (see above).
- **Later (optional):** a Kvantum application style — needs the Kvantum engine,
  not portable on atomic distros.
