#!/usr/bin/env python3
"""Read the SoothifyAfrica design straight from the Figma REST API.

The Figma MCP server is capped at 6 calls/month on the Starter plan; this uses
a personal access token instead, which has no such limit.

  tool/figma.py nodes  <id> ...   save node JSON to tool/.figma_cache/
  tool/figma.py filenodes <id> .. same, via /files?ids= (a separate quota)
  tool/figma.py render <id> ...   render PNGs at 2x
  tool/figma.py pages             list the file's pages
  tool/figma.py fills  <ref> ...  download image fills by imageRef
  tool/figma.py spec   <id>       print positions, styles and fills

THE FILE HAS THREE PAGES and this tool has only ever been pointed at one:

    0:1      Page 1
    124:2    Page 2   <- everything in tool/figma_export/ indexes this
    133:201  Page 3   <- the old page the node index calls superseded

`tool/figma.py pages` lists them. A frame that "is not in the file" is very
often on a page nobody looked at — the Soothify passport waitlist sheet was.
Index a page with `nodes <page-id> depth=1`.
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


def file_nodes(ids):
    """Fetch node JSON through /files?ids= instead of /nodes.

    A third budget, separate from both /nodes and /images, and in practice the
    last one to block — see tool/figma_export/README.md. Returns the same
    documents, so the cache files are interchangeable.
    """
    CACHE.mkdir(parents=True, exist_ok=True)
    data = api(f"files/{KEY}?ids={urllib.parse.quote(','.join(ids))}")
    want, found = set(ids), {}

    def walk(n):
        if n.get("id") in want:
            found[n["id"]] = n
            return
        for c in n.get("children") or []:
            walk(c)

    walk(data["document"])
    for i in ids:
        if i not in found:
            print(f"  !! {i} not returned"); continue
        p = _path(i)
        p.write_text(json.dumps(found[i], indent=1))
        print(f"  {i:>13} {p.stat().st_size/1024:7.1f} KB  {found[i]['name']}")


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


def pages(_args):
    """List the file's pages.

    One cheap call, and the first thing to run when a frame cannot be found:
    every index in tool/figma_export/ covers page 124:2 alone.
    """
    data = api(f"files/{KEY}?depth=1")
    print(f"{data.get('name')}  lastModified {data.get('lastModified')}")
    for p in data["document"].get("children", []):
        print(f"  {p['id']:12s} {p.get('name')}")


def fills(refs):
    """Resolve image fills to their S3 URLs and download them.

    `GET /files/{key}/images` hands back EVERY image fill in the file as
    `imageRef -> URL` in one response. A fourth budget, separate from /nodes,
    /files and /images, and in practice the last of the four to block — so
    when everything else is spent this is often still open.

    Pass the imageRefs read off a frame's fills; with none, it lists how many
    the file holds and writes the whole map for later.
    """
    CACHE.mkdir(parents=True, exist_ok=True)
    data = api(f"files/{KEY}/images")
    meta = data.get("meta") or {}
    urls = meta.get("images") or {}
    (CACHE / "image_fills.json").write_text(json.dumps(urls, indent=1))
    print(f"  {len(urls)} image fills in the file "
          f"-> {CACHE / 'image_fills.json'}")
    for ref in refs:
        url = urls.get(ref)
        if not url:
            print(f"  !! {ref[:12]}… not in the file"); continue
        dest = CACHE / f"fill_{ref[:12]}.png"
        urllib.request.urlretrieve(url, dest)
        print(f"  {ref[:12]}… {dest.stat().st_size / 1024:8.1f} KB -> {dest}")


def icons(args):
    """Export named nodes as SVG into assets/icons/.

      tool/figma.py icons nav_home=135:1 ic_send=135:2 ...

    Batched into one request: the images endpoint charges per call, not per
    node, and the quota is the scarce thing here.
    """
    pairs = [a.split("=", 1) for a in args]
    ids = [nid for _, nid in pairs]
    data = api(
        f"images/{KEY}?ids={urllib.parse.quote(','.join(ids))}&format=svg"
    )
    if data.get("err"):
        sys.exit(f"ERROR: {data['err']}")
    dest_dir = ROOT / "assets" / "icons"
    dest_dir.mkdir(parents=True, exist_ok=True)
    for name, nid in pairs:
        url = data["images"].get(nid)
        if not url:
            print(f"  !! {name} ({nid}) returned no image"); continue
        dest = dest_dir / f"{name}.svg"
        urllib.request.urlretrieve(url, dest)
        print(f"  {name:<26} {dest.stat().st_size:6d} bytes")


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
                    # Opacity, always. The fills line has printed it for ages;
                    # this one did not, so a 5%-black hairline read as solid
                    # black and shipped that way twice — the "Recommended for
                    # you" cards and the Expert Recommendation cards.
                    op = s.get("opacity", 1) * (s["color"].get("a", 1))
                    ex.append(
                        f"stroke {_hex(s['color'])}"
                        + (f" o={op:.2f}" if abs(op - 1) > 1e-6 else "")
                        + f" w={n.get('strokeWeight')}")
            if n.get("cornerRadius") is not None:
                ex.append(f"r={n['cornerRadius']}")
            if n.get("characters"):
                # NOT truncated. It used to clip at 48, which read as the
                # design leaving strings unfinished — a defect was reported
                # against the Cancellation Policy frame on that basis and the
                # frame was fine. If it is long, it is long.
                ex.append(f'"{n["characters"]}"')
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
    {"nodes": nodes, "filenodes": file_nodes, "fills": fills, "pages": pages,
     "render": render, "icons": icons}.get(
        cmd, lambda a: spec(a[0]))(args)
