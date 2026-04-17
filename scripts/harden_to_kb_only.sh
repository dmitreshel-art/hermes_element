#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME_PATH="${1:-/root/element-hermes-assistant/docker-gateway/hermes-home}"
HERMES_BIN="/root/.hermes/venv/bin/hermes"

export HERMES_HOME="$HERMES_HOME_PATH"
mkdir -p "$HERMES_HOME/home"

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
