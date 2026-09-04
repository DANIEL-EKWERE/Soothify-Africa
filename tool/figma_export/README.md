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

## Rate limits

`figma.py` now stops rather than sleeping when Figma's `Retry-After` exceeds
`MAX_WAIT` (180s). A short wait is a per-minute burst and worth retrying; a
multi-day wait means the plan's quota is spent and no amount of waiting inside
one session helps — reach for a plugin export then.

A quota is per token, so a fresh token clears a multi-day block immediately.
Put it in `.figma_token` (gitignored). See `node_index.md` for which node is
which, so a session does not spend calls rediscovering the map.
