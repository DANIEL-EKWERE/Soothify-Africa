# Figma node index

File `NJjQwgwMr44oDKuaaHHKbn`, page `133:201` ("Page 3"), 357 frames.

Sections appear **twice**: a light block, then a dark block further down the
canvas. Only the light node is listed; the dark twin is the same frame at a
larger y. Themes are handled by tokens, so only the light frame was read.

    tool/figma.py nodes <id>        # cache node JSON
    tool/figma.py render <id>       # 2x PNG, for outlined text or to check a fill
    tool/parse_export.py <file>     # measured spec from the cached JSON

## Built

| Screen | Node | Built as |
|---|---|---|
| Home (signed in) | `135:518` | `shell/tabs/home_tab.dart` |
| Recommendation | `135:1372` | `recommendation/` |
| Mood record | `135:2056` | `mood_record/` |
| Journal (empty) | `135:2091` | `journal/journal_screen.dart` |
| Journal composer | `135:2105` | `journal/journal_compose_screen.dart` |
| Plans | `135:2444` | `plans/plans_tab.dart` |
| Discovery | `135:3363` | `discovery/discovery_tab.dart` |
| Community topics | `135:4996` | `community/community_tab.dart` |
| Profile dashboard | `135:8098` | `profile/profile_tab.dart` |
| Meditation | `135:11744` | `library/library_screen.dart` |
| Balance | `135:20551` | `library/library_screen.dart` (same screen) |
| Schedule | `135:20771` | `schedule/schedule_screen.dart` |
| Settings | `135:26963` | `settings/settings_screen.dart` |
| Community welcome | `135:5758` | `community/widgets/community_steps.dart` |
| Create username | `135:5768` | `community/widgets/community_steps.dart` |
| Join discussion | `135:5035` | `community/forum/forum_screen.dart` |
| Start a discussion | `135:5783` | `community/compose/compose_screen.dart` |
| Discussion thread | `135:6190` | `community/thread/thread_screen.dart` |

## Not built

Discovery search (`135:3630`, `135:3821`, `135:3951`, `135:3967`);
Plans checkout (`135:2518`, `135:2526`, `135:2565`, `135:2573`, `135:2584`);
Thread variants (`135:6531`, `135:6599`) and the community moderation screens
(`135:5128`–`135:6456`, a separate manager role);
Profile history and check-ins (`135:8133`, `135:8202`, `135:8481`, `135:8515`);
Profile reminders (`135:8888`–`135:9181`); Notification (`135:8045`);
Meditation and Balance filters (`135:12427`, `135:12573`, `135:19379`,
`135:19491`); Balance KYC (`135:19200`+); Schedule booking flow
(`135:20803`–`135:21767`); Article (`135:22150`).

## Access

Both routes are spent as of 2026-09-04:

- **REST token** — quota exhausted, ~4.5 days (`figma.py` reports this and
  stops rather than sleeping through it). A fresh token clears it at once.
- **MCP server** (`mcp__plugin_figma_figma__*`) — the Starter plan's monthly
  tool-call cap. `get_metadata` still answered once; `get_design_context` was
  refused.

`get_metadata` is worth knowing about: it returns structure, positions, sizes
*and layer names*, and in this file the names carry the copy — enough to build
a screen whose components were already measured elsewhere. It is not enough on
its own, because it carries no fills or type.

## Gotchas

- **Paint opacity.** `parse_export.py` flags anything below full strength with
  `<-- o=0.05`. A plugin export drops these; the REST API keeps them. Reading a
  5%-black stroke at full strength is what drew black borders on the
  "Recommended for you" cards.
- **`gradientHandlePositions` can mislead.** The Profile stats card's handles
  convert to a near-flat leftward wash; the frame Figma actually renders is
  plainly vertical. Render the node and look before trusting the numbers.
- **Sizes are outputs, not constraints.** Pinning a measured width as a fixed
  box caused three overflow bugs. Pin only genuinely fixed boxes.
- **Placeholder copy.** The Plans continue button is labelled "Large button"
  (the component's placeholder) and Community lists "Sad" twice. Both are
  reproduced with a comment rather than silently corrected.
