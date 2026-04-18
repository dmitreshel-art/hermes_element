#!/bin/bash
set -e

HERMES_HOME="${HERMES_HOME:-/home/hermes}"
CONFIG="${HERMES_HOME}/config.yaml"
ENV_FILE="${HERMES_HOME}/.env"

echo "=== Hermes Element Helpdesk ==="
echo "HERMES_HOME: ${HERMES_HOME}"
echo "Config: ${CONFIG}"

if [ ! -f "${CONFIG}" ]; then
    echo "ERROR: config.yaml not found at ${CONFIG}"
    exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
    echo "ERROR: ${ENV_FILE} not found"
    echo "Copy hermes-home/.env.example to hermes-home/.env and fill in real values before launch."
    exit 1
fi

if grep -Eq 'CHANGE_ME|\*\*\*|matrix\.example\.org|@helpdesk:example\.org' "${ENV_FILE}"; then
    echo "ERROR: ${ENV_FILE} still contains placeholder values."
    echo "Fill in real Matrix and LLM credentials before launch."
    exit 1
fi

for VAR in MATRIX_HOMESERVER MATRIX_USER_ID OPENAI_API_KEY; do
    if ! grep -q "^${VAR}=" "${ENV_FILE}"; then
        echo "WARNING: ${VAR} is missing from ${ENV_FILE}"
    fi
done

echo "Knowledge base files:"
ls -1 "${HERMES_HOME}/knowledge/" 2>/dev/null || echo "  (empty)"

echo "Starting Hermes gateway..."
exec hermes --home "${HERMES_HOME}" --config "${CONFIG}" "$@"
