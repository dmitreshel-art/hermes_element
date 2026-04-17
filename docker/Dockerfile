# Hermes Element Helpdesk — isolated Docker image
# Builds from official Hermes release, configures KB-only profile

FROM python:3.12-slim

ARG HERMES_VERSION=v2026.4.16

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends     git curl ca-certificates build-essential &&     rm -rf /var/lib/apt/lists/*

# Install Hermes
RUN pip install --no-cache-dir "hermes-agent==${HERMES_VERSION}" ||     pip install --no-cache-dir git+https://github.com/nicepkg/hermes.git@${HERMES_VERSION} ||     echo "WARN: Hermes install failed; will use bundled src if available"

# Hermes home directory
ENV HERMES_HOME=/home/hermes
RUN mkdir -p ${HERMES_HOME}/knowledge ${HERMES_HOME}/logs

# Copy hermes-home configuration
COPY hermes-home/ ${HERMES_HOME}/

# Fix permissions
RUN chmod +x ${HERMES_HOME}/../docker/entrypoint.sh 2>/dev/null || true

WORKDIR ${HERMES_HOME}

# Expose healthcheck port (gateway internal)
EXPOSE 18789

# Entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gateway"]
