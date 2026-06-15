# @vidguy_ai/cli

[![npm](https://img.shields.io/npm/v/@vidguy_ai/cli.svg)](https://www.npmjs.com/package/@vidguy_ai/cli)
[![license](https://img.shields.io/npm/l/@vidguy_ai/cli.svg)](./LICENSE)

The command-line interface for [VidGuy](https://www.vidguy.ai) — generate
short-form video content (snack packs, faceless/UGC videos, carousels, AI
stories, Studio & Seedance image/video) and publish it to social accounts,
right from your terminal or a coding agent.

It exposes the same surface as the VidGuy MCP server, wrapping the public
`vf_live_` REST API.

## Install

```bash
# zero-install
npx @vidguy_ai/cli --help

# or global
npm i -g @vidguy_ai/cli

# or the convenience installer
curl -fsSL https://raw.githubusercontent.com/vidguy-ai/cli/main/install.sh | sh
```

Requires Node.js ≥ 18.

## Auth

Get a `vf_live_` key from the VidGuy dashboard (Pro or Enterprise plan), then:

```bash
vidguy auth login                 # stores the key in ~/.config/vidguy/config.json
vidguy auth whoami                # plan + credit balance
# or, non-interactively (CI / agents):
export VIDGUY_API_KEY=vf_live_...
```

## Quick start

```bash
vidguy capabilities               # list every command group (offline)
vidguy credits get                # balance + recent transactions
vidguy --json snack list | jq     # machine-readable for scripting

# generate a video and wait for it
vidguy --json --wait video create --topic "3 standup tips" --duration 30 --platform tiktok
```

### Global flags

`--json` (machine output) · `--quiet` · `--no-color` · `--wait` (poll async jobs)
· `--yes` (skip destructive/credit-spending confirms) · `--api-key` / `--base-url`
/ `--profile` · `--poll-interval <s>` · `--timeout <s>`.

### Exit codes

`0` ok · `1` generic · `2` usage · `3` auth (401) · `4` plan required (403) ·
`5` rate limited (429) · `6` insufficient credits (402) · `7` not found (404).

### ⚠ Live publishing

`social post`, `social retry`, and `managed publish` post to **live external
platforms** and are **not retried server-side** — never run them twice for the
same content. They require `--yes` to run non-interactively.

## Using it from a coding agent

The package ships a [SKILL.md](./SKILL.md) with golden-path recipes and a
full command reference. Drop it into your agent's skills directory
(e.g. `.claude/skills/vidguy/SKILL.md`) and the agent can drive the CLI directly.

## How it's built

The command surface is generated from VidGuy's OpenAPI document, so the CLI, the
REST API, and the MCP server can never drift. See
[`docs/CLI.md`](https://www.vidguy.ai) for the architecture.

## License

[MIT](./LICENSE)
