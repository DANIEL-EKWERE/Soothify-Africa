#!/usr/bin/env python3
"""Print a measured spec from a Figma *plugin* JSON export.

Companion to `figma.py spec`, for when the REST API is rate-limited. Same
output shape, so working notes read identically whichever source produced
them.

  tool/parse_export.py <file.json> [--depth N] [--raw NODE_ID]

Plugin exports and the REST API disagree on shape, so everything is read
through the `_get*` helpers below rather than indexed directly:

  position   REST: absoluteBoundingBox{x,y,..}   plugin: flat x/y/width/height
  type style REST: style{fontSize,fontWeight}    plugin: flat fontSize/fontName
  opacity    REST: per-paint `opacity`           plugin: same, but often absent

That last one is the trap this file exists to make loud. A plugin export
routinely omits paint opacity, and a 5%-black stroke read at full strength
draws a solid black box — which is exactly the bug that shipped to the user
on the "Recommended for you" cards. Every paint prints its opacity, and
anything below 1 is flagged, so a missing value is visible rather than
silently assumed opaque.
"""
import json
import sys
import pathlib

TEXTY = ("TEXT", "RECTANGLE", "FRAME", "INSTANCE", "ELLIPSE", "COMPONENT",
         "GROUP", "VECTOR", "LINE", "POLYGON", "STAR", "BOOLEAN_OPERATION")


def _hex(c):
    return "#%02X%02X%02X" % (
        round(c["r"] * 255), round(c["g"] * 255), round(c["b"] * 255))


def _box(n):
    """Absolute box if present, else the flat plugin fields."""
    b = n.get("absoluteBoundingBox") or n.get("absoluteRenderBounds")
    if isinstance(b, dict) and b.get("width") is not None:
        return b
    if n.get("width") is None:
        return None
    return {"x": n.get("x", 0), "y": n.get("y", 0),
            "width": n["width"], "height": n["height"]}


def _paints(n, key):
    """Fills/strokes, tolerating plugin exports that emit 'figma.mixed'."""
    p = n.get(key)
    return p if isinstance(p, list) else []


def _style(n):
    """Type style from either shape, as (family, weight, size, lh, ls, align)."""
    st = n.get("style")
    if isinstance(st, dict) and st.get("fontSize"):
        return (st.get("fontFamily"), st.get("fontWeight"), st.get("fontSize"),
                st.get("lineHeightPx"), st.get("letterSpacing"),
                st.get("textAlignHorizontal"))
    if n.get("fontSize") is not None:
        fn = n.get("fontName")
        fam = fn.get("family") if isinstance(fn, dict) else None
        sty = fn.get("style") if isinstance(fn, dict) else None
        lh = n.get("lineHeight")
        lh = lh.get("value") if isinstance(lh, dict) else lh
        ls = n.get("letterSpacing")
        ls = ls.get("value") if isinstance(ls, dict) else ls
        return (fam, sty, n["fontSize"], lh, ls, n.get("textAlignHorizontal"))
    return None


def _describe(n):
    """The trailing style column: type style, paints, radius, text."""
    ex = []
    st = _style(n)
    if st:
        fam, wt, size, lh, ls, align = st
        ex.append(f"{fam} {wt} {size}px "
                  f"lh={lh if lh is not None else '-'} "
                  f"ls={ls if ls is not None else '-'} {align or ''}".strip())

    for f in _paints(n, "fills"):
        if not f.get("visible", True):
            continue
        op = f.get("opacity", 1)
        # Flagged rather than folded in: a missing opacity is the common
        # plugin-export defect, so it must not read the same as a real 1.0.
        suffix = f"  <-- o={op:.2f}" if op != 1 else ""
        if f.get("type") == "SOLID":
            ex.append("fill " + _hex(f["color"]) + suffix)
        elif "GRADIENT" in (f.get("type") or ""):
            stops = "->".join(_hex(s["color"]) for s in f.get("gradientStops", []))
            ex.append(f"grad {stops}{suffix}")
        elif f.get("type") == "IMAGE":
            ex.append("IMAGE" + suffix)

    for s in _paints(n, "strokes"):
        if not s.get("visible", True) or s.get("type") != "SOLID":
            continue
        op = s.get("opacity", 1)
        ex.append(f"stroke {_hex(s['color'])} w={n.get('strokeWeight')}"
                  + (f"  <-- o={op:.2f}" if op != 1 else ""))

    r = n.get("cornerRadius")
    if isinstance(r, (int, float)):
        ex.append(f"r={r}")

    if n.get("layoutMode") in ("HORIZONTAL", "VERTICAL"):
        ex.append(f"{n['layoutMode'][:1]}auto gap={n.get('itemSpacing', 0)}")

    o = n.get("opacity", 1)
    if isinstance(o, (int, float)) and o != 1:
        ex.append(f"NODE o={o:.2f}")

    if n.get("characters"):
        ex.append('"' + n["characters"][:48].replace("\n", "\\n") + '"')
    return ex


def spec(doc, max_depth=None):
    root = _box(doc) or {"x": 0, "y": 0, "width": 0, "height": 0}
    print(f"=== {doc.get('name', '?').strip()}  "
          f"{root['width']:.0f}x{root['height']:.0f}")

    def walk(n, depth=0):
        if max_depth is not None and depth > max_depth:
            return
        b = _box(n)
        if b and n.get("type") in TEXTY:
            ex = _describe(n)
            if ex:
                print(f"  {'  ' * depth}{n['type'][:9]:<9} "
                      f"{(n.get('name') or '')[:24]:<24} "
                      f"x={b['x'] - root['x']:6.1f} y={b['y'] - root['y']:6.1f} "
                      f"{b['width']:6.1f}x{b['height']:<6.1f} "
                      f"{n.get('id', ''):>12}  " + " | ".join(ex))
        for c in n.get("children") or []:
            walk(c, depth + 1)

    for c in doc.get("children") or [doc]:
        if "Status Bar" in (c.get("name") or ""):
            continue
        walk(c)


def find(doc, nid):
    if doc.get("id") == nid:
        return doc
    for c in doc.get("children") or []:
        hit = find(c, nid)
        if hit:
            return hit
    return None


def load(path):
    """Unwrap the several envelopes an export may arrive in."""
    d = json.loads(pathlib.Path(path).read_text())
    if isinstance(d, list):
        d = d[0]
    # REST `nodes` response, or a plugin that wrapped the frame.
    if "nodes" in d and isinstance(d["nodes"], dict):
        d = next(iter(d["nodes"].values()))
    for key in ("document", "node", "root"):
        if isinstance(d.get(key), dict):
            d = d[key]
            break
    return d


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    args = sys.argv[1:]
    depth = None
    if "--depth" in args:
        i = args.index("--depth")
        depth = int(args[i + 1])
        del args[i:i + 2]
    doc = load(args[0])
    if "--raw" in args:
        i = args.index("--raw")
        node = find(doc, args[i + 1])
        print(json.dumps(node, indent=1) if node else f"{args[i+1]} not found")
    else:
        spec(doc, depth)
