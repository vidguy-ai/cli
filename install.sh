#!/usr/bin/env sh
# VidGuy CLI installer — convenience wrapper around npm.
#
#   curl -fsSL https://raw.githubusercontent.com/vidguy-ai/cli/main/install.sh | sh
#
# The CLI is a Node package, so this just ensures Node is present and installs
# it globally from npm. If you'd rather not install globally, skip this and use
#   npx @vidguy_ai/cli <command>
set -e

PKG="@vidguy_ai/cli"

if ! command -v node >/dev/null 2>&1; then
  echo "✗ Node.js is required (>=18). Install it from https://nodejs.org and re-run." >&2
  exit 1
fi

NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "✗ Node.js >=18 required (found $(node -v))." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "✗ npm not found. It ships with Node.js — reinstall Node from https://nodejs.org." >&2
  exit 1
fi

echo "Installing ${PKG} globally…"
npm install -g "${PKG}"

echo ""
echo "✓ Installed. Get started:"
echo "    vidguy auth login"
echo "    vidguy capabilities"
echo ""
echo "Or run without installing:  npx ${PKG} <command>"
