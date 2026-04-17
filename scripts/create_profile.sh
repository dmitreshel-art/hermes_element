#!/usr/bin/env bash
set -euo pipefail

HERMES_BIN="/root/.hermes/venv/bin/hermes"
PROFILE_NAME="${1:-element-helpdesk}"
PROFILE_DIR="${HOME}/.hermes/profiles/${PROFILE_NAME}"
TEMPLATE_DIR="/root/element-hermes-assistant/profile-template"
ASSET_DIR="/root/element-hermes-assistant"

if [[ ! -x "$HERMES_BIN" ]]; then
  echo "ERROR: hermes binary not found at $HERMES_BIN" >&2
  exit 1
fi

"$HERMES_BIN" profile create "$PROFILE_NAME" >/dev/null 2>&1 || true
mkdir -p "$PROFILE_DIR"

cp "$TEMPLATE_DIR/config.yaml" "$PROFILE_DIR/config.yaml"
cp "$TEMPLATE_DIR/.env.example" "$PROFILE_DIR/.env"
cp "$ASSET_DIR/SYSTEM_PROMPT.md" "$PROFILE_DIR/SYSTEM_PROMPT.md"
cp "$ASSET_DIR/RAG_DESIGN.md" "$PROFILE_DIR/RAG_DESIGN.md"
mkdir -p "$PROFILE_DIR/knowledge"
cp "$ASSET_DIR/knowledge/seed-faq.md" "$PROFILE_DIR/knowledge/seed-faq.md"
cp "$ASSET_DIR/knowledge/intent-catalog.yaml" "$PROFILE_DIR/knowledge/intent-catalog.yaml"
cp "$ASSET_DIR/knowledge/chunking-rules.md" "$PROFILE_DIR/knowledge/chunking-rules.md"

cat <<EOF
Profile prepared: $PROFILE_NAME
Directory: $PROFILE_DIR

Next steps:
1. Edit: $PROFILE_DIR/.env
2. Review: $PROFILE_DIR/config.yaml
3. Extend knowledge in: $PROFILE_DIR/knowledge/
4. Use SYSTEM_PROMPT.md from the profile directory in your launcher/integration
EOF
