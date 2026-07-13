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
| Plasma desktop theme | pinned-Crema panel/widget/tooltip SVGs | `plasma/desktoptheme/Crema/` |
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

## Uninstall

```bash
./install.sh --uninstall
```

Then pick another Global Theme in System Settings to switch away. If you used
`--font`, your previous `kdeglobals` is saved at
`~/.config/kdeglobals.crema-fontbackup`.

## Layout

```
color-schemes/Crema.colors                        # palette mapped to KDE color roles
look-and-feel/com.cafeneurotico.crema.desktop/    # Global Theme package (+ splash/)
desktoptheme/Crema/                               # Plasma desktop theme (colors + SVGs)
konsole/Crema.{colorscheme,profile}              # terminal theme
editor/crema.theme                                # KSyntaxHighlighting theme
fonts/Poppins-*.ttf                               # bundled interface font
install.sh                                        # portable installer
```

## Roadmap

- **Phase 1 — done:** color scheme + Global Theme (Breeze recolored) + installer.
- **Phase 2 — done:** Plasma desktop theme (custom SVGs), Konsole scheme, splash
  screen, and editor syntax theme.
- **Later (optional):** a Kvantum application style (needs the Kvantum engine —
  not portable on atomic distros) and an SDDM login theme (touches system dirs).
