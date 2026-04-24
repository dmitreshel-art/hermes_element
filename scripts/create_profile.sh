#!/usr/bin/env bash
set -euo pipefail

HERMES_BIN="${HERMES_BIN:-/root/.hermes/venv/bin/hermes}"
PROFILE_NAME="${1:-element-helpdesk}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILE_DIR="${HOME}/.hermes/profiles/${PROFILE_NAME}"
TEMPLATE_DIR="$PROJECT_ROOT/profile-template"

if [[ ! -x "$HERMES_BIN" ]]; then
  echo "ERROR: hermes binary not found at $HERMES_BIN" >&2
  exit 1
fi

if [[ ! -d "$PROJECT_ROOT/knowledge" ]]; then
  echo "ERROR: canonical knowledge directory not found: $PROJECT_ROOT/knowledge" >&2
  exit 1
fi

"$HERMES_BIN" profile create "$PROFILE_NAME" >/dev/null 2>&1 || true
mkdir -p "$PROFILE_DIR" "$PROFILE_DIR/knowledge"

cp "$TEMPLATE_DIR/config.yaml" "$PROFILE_DIR/config.yaml"
cp "$TEMPLATE_DIR/.env.example" "$PROFILE_DIR/.env"
cp "$PROJECT_ROOT/SYSTEM_PROMPT.md" "$PROFILE_DIR/SYSTEM_PROMPT.md"
cp "$PROJECT_ROOT/RAG_DESIGN.md" "$PROFILE_DIR/RAG_DESIGN.md"

# Canonical KB lives in the project-level knowledge/ directory.
# Copy the whole tree so the profile is not built from stale Docker test artifacts.
rm -rf "$PROFILE_DIR/knowledge"
mkdir -p "$PROFILE_DIR/knowledge"
cp -a "$PROJECT_ROOT/knowledge/." "$PROFILE_DIR/knowledge/"

cat <<EOF
Profile prepared: $PROFILE_NAME
Directory: $PROFILE_DIR
Canonical knowledge source: $PROJECT_ROOT/knowledge

Next steps:
1. Edit: $PROFILE_DIR/.env
2. Review: $PROFILE_DIR/config.yaml
3. Review copied knowledge in: $PROFILE_DIR/knowledge/
4. Use SYSTEM_PROMPT.md from the profile directory in your launcher/integration
EOF
