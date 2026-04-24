#!/usr/bin/env bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data}"
mkdir -p "$HERMES_HOME" "$HERMES_HOME/home" "$HERMES_HOME/logs" "$HERMES_HOME/sessions"

if [[ ! -f "$HERMES_HOME/config.yaml" ]]; then
  echo "ERROR: missing $HERMES_HOME/config.yaml" >&2
  exit 1
fi

if [[ ! -f "$HERMES_HOME/.env" ]]; then
  echo "ERROR: missing $HERMES_HOME/.env" >&2
  exit 1
fi

if [[ ! -f "$HERMES_HOME/SOUL.md" ]]; then
  echo "WARN: missing $HERMES_HOME/SOUL.md; Hermes will use default identity" >&2
fi

exec "$@"
