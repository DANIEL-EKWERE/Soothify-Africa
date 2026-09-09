#!/usr/bin/env python3
"""Lift a character illustration off a rendered Figma frame.

    tool/extract_figure.py <render.png> <out.png> [tol]

The KYC concern frames flood the screen with a colour and put a soft radial
glow behind the figure, so there is no flat key colour to remove. Two passes
handle it:

1. Flood the background inward from the crop's border. The step tolerance has
   to be *tight* — the glow changes by about 1 per pixel, while the softest
   real edge (Sleep disorder's blue-grey top against the blue ground) is 25.
   A loose tolerance walks straight through that garment and deletes it.
2. Erode what the tight flood leaves behind: a rim of glow still clings to the
   figure. Any surviving pixel that sits next to a cleared one and is within
   `RIM` of what that neighbour used to be is background too.

A luminance floor stops the flood eating dark hair, which on the darker
grounds is close enough in colour to cross into.
"""
import sys
from collections import deque

from PIL import Image

CROP = (150, 560, 640, 1060)   # the focused figure's slot in a 780x1688 render
TOL = 2                        # per-step colour distance for the flood
RIM = 22                       # how close to the old ground a rim pixel is
PASSES = 8


def lum(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def extract(path, tol=TOL):
    sub = Image.open(path).convert("RGB").crop(CROP)
    w, h = sub.size
    sp = sub.load()

    corners = [sp[0, 0], sp[w - 1, 0], sp[0, h - 1], sp[w - 1, h - 1]]
    floor = min(lum(c) for c in corners) - 14

    bg = [[False] * w for _ in range(h)]
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            bg[y][x] = True
            q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if not bg[y][x]:
                bg[y][x] = True
                q.append((x, y))

    while q:
        x, y = q.popleft()
        c = sp[x, y]
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not bg[ny][nx]:
                d = sp[nx, ny]
                if lum(d) < floor:
                    continue
                if max(abs(d[i] - c[i]) for i in range(3)) <= tol:
                    bg[ny][nx] = True
                    q.append((nx, ny))

    for _ in range(PASSES):
        edge = []
        for y in range(h):
            for x in range(w):
                if bg[y][x]:
                    continue
                c = sp[x, y]
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and bg[ny][nx]:
                        if max(abs(c[i] - sp[nx, ny][i]) for i in range(3)) <= RIM:
                            edge.append((x, y))
                        break
        if not edge:
            break
        for x, y in edge:
            bg[y][x] = True

    out = Image.new("RGBA", (w, h))
    op = out.load()
    for y in range(h):
        for x in range(w):
            op[x, y] = (0, 0, 0, 0) if bg[y][x] else (*sp[x, y], 255)
    return out.crop(out.getbbox())


if __name__ == "__main__":
    src, dest = sys.argv[1], sys.argv[2]
    tol = int(sys.argv[3]) if len(sys.argv) > 3 else TOL
    img = extract(src, tol)
    img.save(dest)
    print(f"  {dest}  {img.size}")
