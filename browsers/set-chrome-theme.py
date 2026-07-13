#!/usr/bin/env python3
"""Merge (or reset) a Chromium 'Preferences' theme block.

  set-chrome-theme.py apply <Preferences> <fragment.json>
  set-chrome-theme.py reset <Preferences>

Chromium must be CLOSED, or it rewrites Preferences on exit and loses this.
Writes compact JSON (no spaces), matching how Chromium stores the file.
"""
import json, sys


def deep_merge(a, b):
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict):
            deep_merge(a[k], v)
        else:
            a[k] = v


def main():
    mode, pref = sys.argv[1], sys.argv[2]
    try:
        d = json.load(open(pref))
    except Exception as e:
        print(f"  cannot read {pref}: {e}")
        return 1
    if mode == "apply":
        frag = json.load(open(sys.argv[3]))
        deep_merge(d, frag)
    elif mode == "reset":
        bt = d.get("browser", {}).get("theme", {})
        for k in ("user_color", "user_color2", "saved_local_theme"):
            bt.pop(k, None)
        d.setdefault("extensions", {})["theme"] = {"id": "", "system_theme": 0}
    else:
        print("unknown mode", mode)
        return 2
    json.dump(d, open(pref, "w"), separators=(",", ":"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
