# Manual Figma exports

Drop plugin JSON exports here. Filenames are free-form; the node id in the
name helps (e.g. `discovery_135-3040.json`).

Used when the Figma REST API is rate-limited. `tool/figma.py` reads from the
API; `tool/parse_export.py` reads from these files and prints the same
position/style summary, so either source produces the same working notes.

    tool/parse_export.py discovery_135-3040.json          # measured spec
    tool/parse_export.py discovery_135-3040.json --depth 2   # outline only
    tool/parse_export.py discovery_135-3040.json --raw 135:3041  # one node

## Known gaps in a plugin export

These are why a screen built from an export alone can be wrong. `parse_export`
prints `<-- o=0.05` beside any paint below full strength so the first one is
visible rather than assumed:

0. **Paint opacity is often dropped.** A 5%-black stroke read at full strength
   draws a solid black box — this shipped, on the "Recommended for you" cards.
   Check any border that looks heavier than the design.
1. **Gradients on a frame may carry no fill at all** (the Mood Checker card
   exported empty; its `#2C3FE3 -> #142088` came from the designer).
2. **Outlined text exports as vectors**, with no `characters` to read. Render
   the frame to PNG and read the copy off the image.
3. **Assets are not included.** Export cover art and icons separately:
   right-click -> Export -> PNG at 2x, into `assets/images/`.

## Exporting icons

    tool/figma.py icons nav_home=135:1 ic_send=135:2 ...

Batched into one request and written to `assets/icons/<name>.svg` — the images
endpoint charges per call, not per node, so name every glyph you need in one
go. Raster glyphs (the Profile stat art) go through `render` at 2x instead.

Icon node ids are easiest to find from a cached screen: the design names them
with iconify ids (`solar:arrow-left-linear`, `mynaui:send`), and the rest sit
as the first non-TEXT child of their row or item frame.

## Rate limits

`figma.py` now stops rather than sleeping when Figma's `Retry-After` exceeds
`MAX_WAIT` (180s). A short wait is a per-minute burst and worth retrying; a
multi-day wait means the plan's quota is spent and no amount of waiting inside
one session helps — reach for a plugin export then.

## FOUR endpoints, FOUR budgets (2026-09-26)

`/nodes` and `/images` were known to have separate quotas. There is a third,
and it is the best of them:

    GET /v1/files/{key}?ids=1:2,3:4        <-- its own budget

It returns the same node JSON as `/nodes` — full geometry, full `characters`,
styles and fills — for exactly the subtrees asked for. With both `/nodes` and
`/images` reporting ~1.1 days on the same account, this answered 540 KB for
seven whole frames on the first try.

A fourth was found when the other three were all spent on a fresh account:

    GET /v1/files/{key}/images      -> EVERY image fill in the file, as
                                       imageRef -> S3 URL. Its own budget,
                                       and the last to block.

The URLs it returns are S3, not Figma, so downloading them costs no quota at
all. What it cannot tell you is *which node* uses which ref — that needs node
JSON. On a shared file (this one holds art from several unrelated projects,
514 fills) the refs alone are not enough to identify a screen's artwork.

So the order to try, cheapest and most likely open first:

    GET /v1/me                      -> is the token valid at all
                                       (401 "Invalid token" = wrong/truncated,
                                        403 = no access, 429 = quota)
    GET /v1/files/{key}?depth=1     -> ~1.5KB, proves file access
    GET /v1/files/{key}/images      -> image fills, fourth budget
    GET /v1/files/{key}?ids=...     -> node JSON, third budget
    GET /v1/images/{key}?ids=...    -> renders, second budget
    GET /v1/files/{key}/nodes?ids=  -> the one that blocks first

**`files?ids=` is charged by request size, not per call.** A single-frame
request succeeded on an account where a five-frame one was refused, and the
budget was spent by that one call. Ask for one frame at a time when it is
nearly out.

**`files/{key}/images` needs node JSON to be useful.** It maps
`imageRef -> S3 URL` and says nothing about which node uses which ref. Pair it
with a frame's node JSON — read `fills[].imageRef` off the node you want, then
look the ref up. Also read `scaleMode`: `FILL` is centre-cover, while
`STRETCH` carries an `imageTransform` that is a crop, and ignoring it reframes
the picture.

**Save what a probe returns.** A `files?ids=259:27952` probe answered with
271 KB — the whole Home frame — and it was thrown away because the probe only
printed the size. The next call for the same frame was refused. Probe with
the real call and keep the body.

`tool/figma.py nodes` uses the `/nodes` form. When that is blocked, fetch via
`files?ids=` instead and split the result into `tool/.figma_cache/node_*.json`
— `figma.py spec` then reads them as usual. Prefer this to a render: the JSON
gives exact copy, so no string has to be read off a picture.

A quota is per token *and* rolling — a block that reports days can clear on
its own, so probe with one cheap call before assuming it is still in force. A
fresh token also clears it immediately.
Put it in `.figma_token` (gitignored). See `node_index.md` for which node is
which, so a session does not spend calls rediscovering the map.
