---
name: vidguy
description: Generate short-form video content (snack packs, faceless/UGC videos, carousels, AI stories, Studio/Seedance image & video) and publish it to social accounts using the VidGuy CLI. Use when the user wants to create marketing videos, UGC, snack content, or publish to TikTok/Instagram/YouTube via VidGuy, or mentions the vidguy CLI / vf_live_ API key.
---

# VidGuy CLI

`vidguy` drives the VidGuy platform from the terminal — the same surface as the
VidGuy MCP server, wrapping the public `vf_live_` REST API. Use it to generate
snack packs, videos, UGC, carousels, AI stories, and single Studio/Seedance
assets, then publish them to connected or managed social accounts.

## Setup

Requires a `vf_live_` API key (Pro or Enterprise plan), issued from the VidGuy
dashboard → API keys.

```bash
npx @vidguy_ai/cli auth login          # stores the key in ~/.config/vidguy/config.json
# or, non-interactively (preferred in agents/CI):
export VIDGUY_API_KEY=vf_live_xxxxx
vidguy auth whoami                  # confirm: prints plan + credit balance
```

Run any command with `npx @vidguy_ai/cli <args>` (or install globally:
`npm i -g @vidguy_ai/cli`).

## How to drive it (agent tips)

- **Always check credits before spending:** `vidguy credits get`.
- **Use `--json` for everything you parse**, then pipe to `jq`:
  `vidguy --json snack list | jq '.snacks[].id'`.
- **Async jobs:** add `--wait` to block until the job finishes (it polls and
  prints progress to stderr). Without `--wait` you get a `jobId` to poll
  yourself with the matching `... get-job`/`... job`/`... status` command.
- **Non-interactive credit-spending or destructive actions need `--yes`** (or a
  TTY to confirm). Without it they abort.
- **Branch on exit codes:** `0` ok · `1` generic · `2` usage · `3` auth (401) ·
  `4` plan required (403) · `5` rate limited (429) · `6` insufficient credits
  (402) · `7` not found (404).
- **Discover the whole surface offline:** `vidguy capabilities` (add `--json`).
- **Escape hatch:** most `create` commands accept `--body-json '{...}'` to pass
  fields not exposed as flags (explicit flags win over JSON keys).

## ⚠ Live-publishing safety

`vidguy social post`, `vidguy social retry`, and `vidguy managed publish` post
to **live external platforms** and are **not retried server-side**. **Never run
them twice for the same content** — a retry on a network blip can double-post.
They require `--yes` to run non-interactively.

## Golden-path recipes

### 1. Snack pack for a brand
```bash
vidguy credits get
vidguy brand create --name "Acme" --industry "SaaS" \
  --description "Acme builds time-tracking software for remote teams."
# → returns a brand id
vidguy snack estimate --render
vidguy --json --wait snack create --brand <brandId> --render   # waits ~2-3 min
```

### 2. Faceless video → publish to a connected account
```bash
vidguy --json --wait video create \
  --topic "3 tips for faster standups" --duration 30 --platform tiktok
# grab the outputUrl from the finished job, then:
vidguy social brands                          # find a brandId
vidguy social accounts <brandId>              # find an accountId
vidguy social post --brand <brandId> --account <accountId> \
  --kind video --video-url <outputUrl> --caption "Standups, but fast" --yes
```

### 3. UGC video with a character
```bash
vidguy character library                      # pick a preset, or:
vidguy character create --name "Maya" --prompt "friendly 20s barista, 9:16" --yes
# → characterId
vidguy --json --wait video create \
  --topic "why our cold brew slaps" --duration 20 --platform reels \
  --body-json '{"videoType":"ugc","characterId":"<characterId>","script":"..."}'
```

### 4. Studio image → use as a reference
```bash
vidguy --json studio image --prompt "minimalist product hero, soft light" --yes
# take the asset URL from the result, feed it as a reference image:
vidguy --json --wait carousel create --reference-image <assetUrl> --prompt "9 angles" --yes
```

### 5. Upload local footage → AI Edit
```bash
vidguy --json edit upload ./clip.mp4          # CLI does the presigned PUT for you
# → r2Key
vidguy --json --wait edit create --r2-key <r2Key> --file-name clip.mp4 \
  --duration 45 --recipe polished-broll --caption-style bold --yes
```

## Command reference

### `auth` — Manage API credentials

| Command | Description |
|---|---|
| `vidguy auth login [key]` | Store a vf_live_ API key (validated against the API) |
| `vidguy auth whoami` | Show the active key's plan and credit balance |
| `vidguy auth logout` | Remove the stored key for the active profile |

### `credits` — Credit balance and history

| Command | Description |
|---|---|
| `vidguy credits get` | Show balance, plan allotment, and recent transactions |

### `capabilities` — List tool groups and operations this CLI exposes (offline)

| Command | Description |
|---|---|
| `vidguy capabilities` | List tool groups and operations this CLI exposes (offline) |

### `brand` — Snack-generation brands (your end-customers)

| Command | Description |
|---|---|
| `vidguy brand list` | List your registered brands |
| `vidguy brand get <id>` | Fetch one brand by id |
| `vidguy brand create` | Register a new brand |
| `vidguy brand update <id>` | Patch brand fields (pass only what changes) |
| `vidguy brand delete <id>` | Delete a brand (existing snacks are preserved) |

### `snack` — Generate and inspect snack packs

| Command | Description |
|---|---|
| `vidguy snack estimate` | Estimate the credit cost of a snack generation (local, no API call) |
| `vidguy snack create` | Start a snack generation job for a brand (async) |
| `vidguy snack get-job <jobId>` | Poll a snack generation job |
| `vidguy snack get <id>` | Fetch one snack post (with manifest) |
| `vidguy snack list` | List generated snack posts |

### `video` — Video projects (Quick Create)

| Command | Description |
|---|---|
| `vidguy video create` | Create a video from a brief (async) |
| `vidguy video get <id>` | Fetch a video project (status, outputUrl, assets) |
| `vidguy video list` | List your video projects (newest first) |
| `vidguy video cancel <id>` | Cancel a queued video (credits refunded) |

### `job` — Generic async API jobs

| Command | Description |
|---|---|
| `vidguy job create` | Create an API job for an offering |
| `vidguy job get <id>` | Poll any async job |

### `carousel` — 9-image carousel from a reference image

| Command | Description |
|---|---|
| `vidguy carousel create` | Generate a 9-tile carousel (async, ~20 credits) |

### `slides` — Portrait 5-slide deck from a reference image

| Command | Description |
|---|---|
| `vidguy slides create` | Generate a 5-slide portrait deck (async, ~20 credits) |

### `story` — Dialogue-first short drama from a cast image

| Command | Description |
|---|---|
| `vidguy story create` | Generate an AI Story (async, 50 / 80 credits) |

### `studio` — Single image/video via the model catalog

| Command | Description |
|---|---|
| `vidguy studio models` | List the Studio model catalog |
| `vidguy studio image` | Generate one image (SYNC — asset URL in the result) |
| `vidguy studio video` | Generate one video clip (ASYNC) |
| `vidguy studio job <id>` | Poll a Studio video generation |

### `seedance` — BytePlus Seedance video / Seedream image

| Command | Description |
|---|---|
| `vidguy seedance actors` | List the curated digital-actor catalogue |
| `vidguy seedance optimize-prompt` | Expand a short idea into a production prompt |
| `vidguy seedance video` | Generate a Seedance 2.0 video (async) |
| `vidguy seedance image` | Generate a Seedream image / storyboard / character-sheet (async) |
| `vidguy seedance job <id>` | Poll a SeedDance job (video or image) |

### `post` — Post-processing on a completed project

| Command | Description |
|---|---|
| `vidguy post upscale <projectId>` | Upscale a completed project to 1080p (sync, 10 credits) |
| `vidguy post voice-enhance <projectId>` | Re-voice the audio (sync, 10 credits) |
| `vidguy post dub <projectId>` | Dub into another language (async, 10 credits) |
| `vidguy post dub-status <projectId>` | Poll a dub job |

### `edit` — AI Edit — polish uploaded footage

| Command | Description |
|---|---|
| `vidguy edit upload <file>` | Upload a source video (≤2GB) and get its r2Key |
| `vidguy edit create` | Create an AI Edit job from an uploaded r2Key (async) |
| `vidguy edit status <projectId>` | Poll an AI Edit project |

### `swap` — Character Swap — swap a character onto a driving video

| Command | Description |
|---|---|
| `vidguy swap upload <file>` | Upload a character-image (≤20MB) or driving-video (≤2GB) and get its r2Key |
| `vidguy swap create` | Create a Character Swap from two uploaded r2Keys (async) |
| `vidguy swap status <projectId>` | Poll a Character Swap project |

### `asset` — Provide images/videos without holding bytes

| Command | Description |
|---|---|
| `vidguy asset import <url>` | Server-fetch a public URL into R2 → stable URL |
| `vidguy asset upload <file>` | Upload a local image/video and get its public URL |

### `character` — Saved actors for UGC

| Command | Description |
|---|---|
| `vidguy character list` | List your saved characters (actors) |
| `vidguy character library` | List the preset character library |
| `vidguy character create` | Create a saved actor (clone library / save image / AI-generate) |

### `social` — Publish to your own connected accounts

| Command | Description |
|---|---|
| `vidguy social brands` | List your connected-account brands |
| `vidguy social brand-create` | Create a connected-account brand |
| `vidguy social accounts <brandId>` | List active connected accounts on a brand |
| `vidguy social posts` | List posts (queue/calendar view) |
| `vidguy social post-get <id>` | Fetch one connected-account post |
| `vidguy social post` | Publish/schedule to 1+ connected accounts (LIVE — never run twice) |
| `vidguy social cancel <id>` | Cancel a scheduled post / remove a draft|failed row |
| `vidguy social retry <id>` | Re-dispatch a failed post (LIVE — never run twice) |

### `managed` — Publish to hosted/managed accounts (done-for-you)

| Command | Description |
|---|---|
| `vidguy managed accounts` | List your managed accounts |
| `vidguy managed account <id>` | Get one managed account (+ daily cap usage) |
| `vidguy managed posts <id>` | List a managed account's posts |
| `vidguy managed publish <id>` | Publish-now to a managed account (LIVE — never run twice; 2/account/24h) |

---
*Generated from the CLI's command tree — do not edit by hand. Regenerate with
`npx tsx packages/cli/scripts/gen-skill.ts`.*
