# Home screen — measured spec

Source: plugin JSON export, `Home screen/Unsigned` (Figma `1051:8496`).
NOT the signed-in variant (`655:5671`) — see "Gaps" below.

Frame 390x1226, bg `#F5FBFF`.

## Header — 342x44, row, space-between
- Greeting "Good morning" — Nunito Sans 20 / w400 / `#2F6FED`
- Sub "How are you today?" — Nunito Sans 12 / w300 / `#000000`
- Column gap 1 between them
- Right cluster 76x44, row, gap 8:
  - dark-mode toggle 24x24, vector `#1F2EB1`
  - bell: ellipse 44x44 white, 1px border `#CBD0D8`

## Mood Checker card — 345x88, radius 8, row, gap 15, padding L/R 23
- icon 38x38
- text column gap 2:
  - "Mood Checker" — Nunito Sans 20 / w700 / `#FEFEFE`
  - "Take a moment to check in with yourself.\nBe gentle and kind,
    acknowledging how you truly feel." — Nunito Sans 10 / w400 / `#FEFEFE`
- trailing arrow-right icon
- Fill: linear gradient `#2C3FE3` → `#142088` (from the designer; the export
  carried no fill for this frame). Direction assumed left-to-right.

## Explore — 342x148, column, gap 16
- "Explore" — Nunito Sans 16 / w600 / `#263238`
- Row of 3, gap 21; each tile 100x111, column, gap 8:
  - box 100x90, white, 1px border `#EADDFF`, radius 8, padding 10, centred
    - image 56x56 (Balance is 64x64)
  - label — Nunito Sans 10 / w700 / `#263238`, centred
- Labels: **Meditation**, **Schedule Session**, **Balance**

## Recommended for you — 342x419, column, gap 16
- Heading — Nunito Sans 16 / w600 / `#263238`
- List gap 8; each card 342x122, white, 1px border `#263238` **at 4%**
  (the export drops stroke opacity; full strength draws a black box), radius 12,
  row, gap 16, padding L/R 14:
  - cover 92x92, radius 6
  - text column 112x54, gap 5:
    - category — Nunito Sans 10 / w600 / `#263238`  ("Burnout relief")
    - title    — Nunito Sans 14 / w600 / `#263238`  ("Daily focus")
    - author   — Nunito Sans 10 / w600 / `#263238`  ("Jacob Samuel")
  - right rail 29x94, column, gap 45: heart, then lock in a 29x29 ellipse
    `#ECECEC`
  - category pill 46x11, white, radius 10 — label Nunito Sans 8 / w600
  - duration pill 36x10, `#484747`, radius 10, row gap 3 — play icon +
    "45:00" Nunito Sans 6 / w600 / `#FEFEFE`
  - rating pill 21x8, `#484747`, radius 10 — star + "4.6" same type
- Titles: Daily focus, Breath work, Mindfulness

## Popular Content — 366x204, column, gap 16
- Row, space-between:
  - "Popular Content" — **Nunito** 16 / w500 / `#000000`
  - "See All" — Nunito Sans 14 / w600 / `#2F6FED`
- Row of 3, gap 20; each 159x166:
  - cover 159x166, radius 8
  - title pill, white, radius 10 — Nunito Sans 8 / w600 / `#263238`
  - footer row gap 86: duration pill + rating pill
- Titles: Unshakeable, Hope in the Shadows, Breaking Bad Habit

## AI Therapy Assist — floating 70x70
Circle, image fill, radius 38, shadow `0 0 4 rgba(0,0,0,0.32)`.

## Gaps this export does not cover
0. **Stroke and fill opacity are dropped.** A border reported as plain
   `#263238` is `#263238` at 0.04 in the file. Check any near-black outline
   against a screenshot before trusting it.
1. Every INSTANCE exports as 0x0 with no children — so the **bottom nav**,
   all **icons** (arrow, heart, lock, play, bell, star) have no detail.
2. No `imageRef`s — covers, Explore tile art, the Mood Checker icon and the
   AI Assist avatar all need exporting as PNGs.
4. This is the **Unsigned** variant; the signed-in one (`655:5671`) may differ.
