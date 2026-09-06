# Filter screens — measured spec

Three frames, reached from the filter glyph in a library's search row.

Balance draws its own copies (`135:19379`, `135:19491`, `135:20011`). Fetched
and compared: every string, position and size matches Meditation's exactly, so
one set of screens serves both — the call `LibrarySection` already makes for
the library screen itself. Raw JSON is cached under `tool/.figma_cache/`
(`nodes_filters.json` for Meditation, `node_135_19379.json` and siblings for
Balance).

Built as `lib/app/modules/user/filters/`, routes `/filters/duration`,
`/filters/more`, `/filters/style`.

## Shared chrome

Frame background `#F5FBFF` (`appTheme.background`). Header at y=65: a 24x24
`chevron-left` at x=24, heading centred, Nunito Sans Bold 16 `#263238`. Apply
is the "Full button / Large (Disabled)" instance — 343x52, radius 8, fill
`#8B93D7` at 45% — i.e. the frames all show the nothing-picked state.

Each frame carries the bottom navigation, so these push over the shell.

## Duration — `135:12427`, 390x844

Chips from y=134. Two columns 162 wide at x=24 and x=202, 18 apart; 37 tall,
radius 20, fill `#FEFEFE`, 1px `#263238` hairline; label Nunito Sans Regular
12 centred. Row pitch 45 (37 + 8).

    5 minutes    10 minutes
    15 minutes   20 minutes
    30 minutes   40 minutes
    50 minutes   See More...

Apply at y=696. Between the chips (ending y=306) and Apply the frame leaves
~390 blank.

## More Filters — `135:12573`, 390x1661

Five groups, each a Nunito Sans Bold 14 label over the same chip grid, split
by a 2px `#999999` rule (y=373, 786, 1064, 1342).

| Group | y | Options (reading order) |
|---|---|---|
| Teacher | 127 | Alex Artymiak, Ali Owens, Rita, Annie, Chelsey Korus, Westernman, Mark Owen |
| Focus | 413 | Morning, Evening + Sleep, Core, Strenght\*, Stretch + Release, Calm, Basics, Prenatal, Postnatal, Back Care, Energy Balance, Breath, Inversion + Arm Balance |
| Body parts | 826 | Arm, Shoulder, Knees, Low Back, Immune Sysytem\*, Upper Back, Legs |
| Prop | 1104 | No Props, Chair, Wall Space, Backless Chair, Magic Circle, Eye Pillow, Small  Stability Ball\* |
| Music | 1382 | Music, No Music |

Apply at y=1512.

\* The file misspells "Strenght" and "Immune Sysytem", and doubles a space in
"Small  Stability Ball". Corrected in `FilterGroup`; a test asserts the typos
never come back.

## Style — `135:12833`, 390x909

Seven cards, 140x122, radius 8, same fill and hairline as a chip. Two columns
at x=43 and x=207, 24 apart both ways. Title Nunito Sans Bold 14 over a
Nunito Sans Regular 10 description, both centred.

| Title | Description |
|---|---|
| Mindfulness | Paying attention to the present moment without judging it |
| Focused | Concentrating on one thing, word or phrase to relax deeply |
| Transcendental | Silently repeating a word or phrase to relax deeply |
| Box Breathing | Breathing in, holding, breathing out, and holding again for the same amount of time |
| Reflection | Thinking deeply about a specific idea or question |
| Walking | Walking slowly and noticing each step and how your body feels |
| Breathwork | Doing special breathing exercises to feel better and think clearly |

Apply at y=732. (The frame also carries a stray second Apply at y=902, below
the bottom nav — leftover, ignored.)

## What the frames do not say, and what was decided

- **No route between the three.** Each is drawn standing alone, but there is
  one filter glyph to reach all three. Duration is the entry point and carries
  links to Style and More Filters, in the blank it leaves under its chips.
- **No selected state is drawn** — every chip is unselected in all three
  frames. Unlike a Community topic chip, an unselected filter chip already has
  a hairline, so selection fills the pill with `actionFill` and flips the
  label white, matching the primary action button.
- **"See More..." has nothing behind it.** It fills the trailing odd cell in
  every group with an odd chip count (Music, with two, has none) and no longer
  list is drawn anywhere in the file. It says so when tapped rather than
  expanding to the same seven names.
- **Only duration narrows anything.** It is the one group `MediaItem` can
  answer. A chip is a bucket, not an exact length — a 12-minute session
  belongs to "10 minutes" — otherwise most of the catalogue is unreachable.
  The rest is recorded and goes to the API when there is one.
- **The glyph gained a count badge**, because filtering can empty a shelf and
  the frames give no other sign that a filter is on.
