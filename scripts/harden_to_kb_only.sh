#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HERMES_HOME_PATH="${1:-$PROJECT_ROOT/hermes-home}"
HERMES_BIN="${HERMES_BIN:-/root/.hermes/venv/bin/hermes}"

export HERMES_HOME="$HERMES_HOME_PATH"
mkdir -p "$HERMES_HOME/home"

if [[ ! -x "$HERMES_BIN" ]]; then
  echo "ERROR: hermes binary not found at $HERMES_BIN" >&2
  exit 1
fi

# Disable everything except file tools so the agent can only read/search local KB.
for toolset in web browser terminal code_execution vision image_gen moa tts skills todo memory session_search clarify delegation cronjob messaging homeassistant; do
  "$HERMES_BIN" tools disable "$toolset" >/dev/null || true
done

# Ensure file stays enabled.
"$HERMES_BIN" tools enable file >/dev/null || true

cat <<EOF
KB-only hardening applied to: $HERMES_HOME_PATH
Expected enabled toolsets: file only
Verify with:
  HERMES_HOME=$HERMES_HOME_PATH $HERMES_BIN tools list
EOF
