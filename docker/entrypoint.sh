#!/bin/bash
set -e

HERMES_HOME="${HERMES_HOME:-/home/hermes}"
CONFIG="${HERMES_HOME}/config.yaml"

echo "=== Hermes Element Helpdesk ==="
echo "HERMES_HOME: ${HERMES_HOME}"
echo "Config: ${CONFIG}"

# Verify config exists
if [ ! -f "${CONFIG}" ]; then
    echo "ERROR: config.yaml not found at ${CONFIG}"
    exit 1
fi

# Verify .env exists
if [ ! -f "${HERMES_HOME}/.env" ]; then
    echo "WARNING: .env not found at ${HERMES_HOME}/.env"
    echo "Copy .env.example to .env and fill in your values"
fi

# Verify critical env vars
for VAR in MATRIX_HOMESERVER OPENAI_API_KEY; do
    if [ -z "${!VAR}" ] && ! grep -q "^${VAR}=" "${HERMES_HOME}/.env" 2>/dev/null; then
        echo "WARNING: ${VAR} is not set"
    fi
done

# List knowledge base files
echo "Knowledge base files:"
ls -1 "${HERMES_HOME}/knowledge/" 2>/dev/null || echo "  (empty)"

echo "Starting Hermes gateway..."
exec hermes --home "${HERMES_HOME}" --config "${CONFIG}" "$@"
