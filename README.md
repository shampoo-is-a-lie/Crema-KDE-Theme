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

## What this is (Phase 1)

A **portable, user-level** Global Theme. It:

- installs entirely into your home (`~/.local/share`, `~/.config`) — **no root, no
  system files touched, fully reversible**;
- ships a **Crema color scheme** that recolors Plasma and Breeze apps;
- uses the built-in **Breeze** widget style + window decoration (already
  rounded in Plasma 6) recolored by the scheme;
- bundles the **Poppins** font (optional to enable; titlebar uses Poppins SemiBold);
- **does not change your wallpaper**.

Copy this folder to any machine and run `./install.sh` — that's the whole thing.

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
color-schemes/Crema.colors                        # the palette mapped to KDE roles
look-and-feel/com.cafeneurotico.crema.desktop/    # the Global Theme package
fonts/Poppins-*.ttf                               # bundled interface font (Regular/Medium/SemiBold/Bold)
install.sh                                        # portable installer
```

## Roadmap

- **Phase 2 (optional):** a bespoke Kvantum application style and a recolored
  Plasma desktop theme (custom panel/widget SVGs) for a fully custom look,
  plus an optional SDDM login theme.
