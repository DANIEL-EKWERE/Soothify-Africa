# Filter screens — measured spec

Three frames, reached from the filter glyph in a library's search row. Balance
has its own copies at the same shapes (`135:19379`, `135:19491`, `135:20011`).

Raw JSON for all three is cached at `tool/.figma_cache/nodes_filters.json`.

## Duration — `135:12427`, 390x844

Heading "Duration" at y=65. Chips in two columns, 45 apart:

    5 minutes    10 minutes
    15 minutes   20 minutes
    30 minutes   40 minutes
    50 minutes   See More...

"Apply" at y=703.

## More Filters — `135:12573`, 390x1661

Heading "More Filters" at y=66.5, then five groups, each two columns 45 apart
and each ending in a "See More..." link:

| Group | y | Options |
|---|---|---|
| Teacher | 127 | Ali Owens, Alex Artymiak, Rita, Annie, Westernman, Chelsey Korus, Mark Owen |
| Focus | 413 | Morning, Evening + Sleep, Strenght*, Core, Stretch + Release, Calm, Prenatal, Basics, Postnatal, Back Care, Energy Balance, Breath, Inversion + Arm Balance |
| Body parts | 826 | Shoulder, Arm, Low Back, Knees, Upper Back, Immune Sysytem*, Legs |
| Prop | 1104 | No Props, Chair, Wall Space, Backless Chair, Magic Circle, Eye Pillow, Small  Stability Ball* |
| Music | 1382 | No Music, Music |

"Apply" at y=1512.

\* The file misspells "Strenght" and "Immune Sysytem", and doubles a space in
"Small  Stability Ball". Correct them in code and note it here rather than
reproducing typos in shipped copy.

## Style — `135:12833`, 390x909

Heading "Style" at y=66.5. Two columns of cards, each a title over a
description:

| Title | Description |
|---|---|
| Focused | Concentrating on one thing, word or phrase to relax deeply |
| Mindfulness | Paying attention to the present moment without judging it |
| Transcendental | Silently repeating a word or phrase to relax deeply |
| Box Breathing | Breathing in, holding, breathing out, and holding again |
| Walking | Walking slowly and noticing each step and how your body feels |
| Reflection | Thinking deeply about a specific idea or question |
| Breathwork | Doing special breathing exercises to feel better and think clearly |

"Apply" at y=739.

## Note

Each frame carries the bottom navigation, so these are pushed routes over the
shell rather than full-screen sheets.
