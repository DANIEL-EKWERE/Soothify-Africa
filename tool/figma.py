#!/usr/bin/env python3
"""Read the SoothifyAfrica design straight from the Figma REST API.

The Figma MCP server is capped at 6 calls/month on the Starter plan; this uses
a personal access token instead, which has no such limit.

  tool/figma.py nodes  <id> ...   save node JSON to tool/.figma_cache/
  tool/figma.py render <id> ...   render PNGs at 2x
  tool/figma.py spec   <id>       print positions, styles and fills

Note the real design lives on page 55:23 ("App UI Design"); the API's page
listing only reports the style-guide page.
"""
import json, os, sys, time, urllib.error, urllib.request, urllib.parse, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
CACHE = ROOT / "tool" / ".figma_cache"
# The design moved to a new file. Override with FIGMA_FILE_KEY if it moves
# again; the old file was WCc0XlMxVrypxll8CqWhPp.
KEY = os.environ.get("FIGMA_FILE_KEY", "NJjQwgwMr44oDKuaaHHKbn")
# Longest 429 wait worth sitting through; past this the quota is spent.
MAX_WAIT = 180


def token():
    p = ROOT / ".figma_token"
    if not p.exists():
        sys.exit("missing .figma_token — see tool/README.md")
    return p.read_text().strip()


def api(path, attempts=6):
    """GET with backoff.

    Figma rate-limits per minute and answers 429; image rendering burns budget
    fastest. Retrying with a widening gap turns a hard failure into a wait.
    """
    req = urllib.request.Request(
        f"https://api.figma.com/v1/{path}", headers={"X-Figma-Token": token()}
    )
    delay = 20
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code != 429 or attempt == attempts - 1:
                raise
            retry_after = e.headers.get("Retry-After")
            wait = int(retry_after) if (retry_after or "").isdigit() else delay
            # Figma answers a per-minute burst with a short Retry-After, but a
            # spent monthly quota with days. Sleeping on the latter looks
            # identical to a hung process, so anything beyond MAX_WAIT stops
            # and says so rather than waiting it out.
            if wait > MAX_WAIT:
                sys.exit(
                    f"rate limited: Figma asks for {wait}s "
                    f"(~{wait / 86400:.1f} days) — the quota is spent, not a "
                    f"burst. Use a plugin JSON export instead; see "
                    f"tool/figma_export/README.md")
            print(f"  rate limited; retrying in {wait}s "
                  f"({attempt + 1}/{attempts - 1})", flush=True)
            time.sleep(wait)
            delay = min(delay * 2, 120)


def _path(nid):
    return CACHE / f"node_{nid.replace(':', '_')}.json"


def nodes(ids, depth=None):
    """Fetch node JSON.

    `depth` limits how far down the tree the API walks. A full 390x1226 screen
    is a large, expensive request that the rate limiter rejects; pulling the
    outline first and drilling into specific children is far cheaper.
    """
    CACHE.mkdir(parents=True, exist_ok=True)
    # ids may carry a trailing "depth=N" argument from the command line.
    depth = depth or next(
        (int(a.split("=")[1]) for a in ids if a.startswith("depth=")), None)
    ids = [i for i in ids if not i.startswith("depth=")]

    query = f"files/{KEY}/nodes?ids={urllib.parse.quote(','.join(ids))}"
    if depth:
        query += f"&depth={depth}"
    data = api(query)
    for i in ids:
        n = data["nodes"].get(i)
        if not n:
            print(f"  !! {i} not returned"); continue
        p = _path(i) if not depth else CACHE / f"node_{i.replace(':', '_')}_d{depth}.json"
        p.write_text(json.dumps(n["document"], indent=1))
        print(f"  {i:>13} {p.stat().st_size/1024:7.1f} KB  {n['document']['name']}")


def render(ids, scale=2):
    CACHE.mkdir(parents=True, exist_ok=True)
    data = api(
        f"images/{KEY}?ids={urllib.parse.quote(','.join(ids))}&format=png&scale={scale}"
    )
    if data.get("err"):
        sys.exit(f"ERROR: {data['err']}")
    for i, url in data["images"].items():
        if not url:
            print(f"  !! {i} no image"); continue
        dest = CACHE / f"img_{i.replace(':', '_')}.png"
        urllib.request.urlretrieve(url, dest)
        print(f"  {i:>13} {dest.stat().st_size/1024:7.1f} KB -> {dest}")


def _hex(c):
    return "#%02X%02X%02X" % (
        round(c["r"] * 255), round(c["g"] * 255), round(c["b"] * 255))


def spec(nid):
    p = _path(nid)
    if not p.exists():
        nodes([nid])
    d = json.loads(p.read_text())
    o = d["absoluteBoundingBox"]
    print(f"=== {nid} :: {d['name'].strip()}  {o['width']:.0f}x{o['height']:.0f}")

    def walk(n):
        b = n.get("absoluteBoundingBox")
        if b and n["type"] in ("TEXT", "RECTANGLE", "FRAME", "INSTANCE", "ELLIPSE"):
            ex = []
            st = n.get("style")
            if st:
                ex.append(
                    f"{st.get('fontFamily')} {st.get('fontWeight')} "
                    f"{st.get('fontSize')}px lh={st.get('lineHeightPx', 0):.1f} "
                    f"ls={st.get('letterSpacing', 0):.2f} {st.get('textAlignHorizontal')}")
            for f in n.get("fills") or []:
                if not f.get("visible", True):
                    continue
                if f["type"] == "SOLID":
                    op = f.get("opacity", 1)
                    ex.append("fill " + _hex(f["color"]) + (f" o={op:.2f}" if op != 1 else ""))
                elif "GRADIENT" in f["type"]:
                    ex.append("grad " + "->".join(_hex(s["color"]) for s in f["gradientStops"]))
                elif f["type"] == "IMAGE":
                    ex.append("IMAGE")
            for s in n.get("strokes") or []:
                if s["type"] == "SOLID":
                    ex.append(f"stroke {_hex(s['color'])} w={n.get('strokeWeight')}")
            if n.get("cornerRadius") is not None:
                ex.append(f"r={n['cornerRadius']}")
            if n.get("characters"):
                ex.append(f'"{n["characters"][:48]}"')
            if ex:
                print(f"  {n['type'][:9]:<9} {n.get('name','')[:24]:<24} "
                      f"x={b['x']-o['x']:6.1f} y={b['y']-o['y']:6.1f} "
                      f"{b['width']:6.1f}x{b['height']:<6.1f} {n['id']:>12}  " + " | ".join(ex))
        for c in n.get("children") or []:
            walk(c)

    for c in d.get("children") or []:
        if "Status Bar" in c.get("name", ""):
            continue
        walk(c)


if __name__ == "__main__":
    cmd, args = sys.argv[1], sys.argv[2:]
    {"nodes": nodes, "render": render}.get(cmd, lambda a: spec(a[0]))(args)
