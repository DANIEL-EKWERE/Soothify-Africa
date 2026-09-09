# Reference renders

2x PNGs of the current design, straight from the `/images` endpoint. Kept in
the repo because the `/nodes` endpoint is usually rate-limited and these are
what the comparison notes below are measured against.

| File | Frame | Node |
|---|---|---|
| `mood_male_down.png` | Mood checker/male/ feeling down | 176:31360 |
| `mood_male_happy.png` | Mood checker/male/happy | 176:31381 |
| `mood_female_down.png` | Mood checker/female/ feeling down | 176:31453 |
| `mood_record.png` | Mood record | 176:31537 |
| `profile_dashboard.png` | Profile/dashboard | 176:34109 |
| `profile_history.png` | Profile/history | 176:34144 |
| `profile_unsigned.png` | Profile/unsigned/not logged in | 176:34542 |
| `aihub_unexpanded.png` | AI Hub \| Unexpanded | 176:56425 |
| `aihub_chat.png` | AI Hub \| Expanded \| Chat | 176:56395 |
| `onboarding_slide1.png` | Welcome screen (old file, same content) | — |

## Getting more of these

**The `/images` endpoint has its own quota, separate from `/nodes`.** When
`tool/figma.py nodes` returns 429 for days, `tool/figma.py render` will very
often still work. That was missed for a whole session; check it before
declaring the API unusable or asking for another token.

    tool/figma.py render 176:56425 176:56395

A quick way to tell what is actually blocked, without spending much:

    GET /v1/me                      -> is the token valid at all (403 = bad)
    GET /v1/files/{key}?depth=1     -> ~1.5KB, cheap, proves file access
    GET /v1/files/{key}/nodes?ids=  -> the expensive one, blocks first
    GET /v1/images/{key}?ids=       -> separate budget, usually still open

A 429 means the token is fine and the *account* is out of budget for that
endpoint, so a fresh token does not help. A 403 means the token is wrong.
