# Hermes Element Helpdesk — isolated Docker image
# Portable image for Matrix/Element helpdesk deployment

FROM python:3.12-slim

ARG HERMES_GIT_REF=main

# System deps for Hermes + Matrix encryption support
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates build-essential libolm-dev libffi-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes and Matrix-related runtime deps.
# In practice PyPI resolution for hermes-agent may be unavailable, so install
# directly from the official GitHub repository.
RUN pip install --no-cache-dir \
    "git+https://github.com/NousResearch/hermes-agent.git@${HERMES_GIT_REF}" \
    mautrix \
    python-olm

ENV HERMES_HOME=/home/hermes
RUN mkdir -p ${HERMES_HOME} ${HERMES_HOME}/knowledge ${HERMES_HOME}/logs

# Copy default portable home into the image. In production docker-compose mounts
# ../hermes-home over /home/hermes so the operator can edit config/KB/.env on host.
COPY hermes-home/ ${HERMES_HOME}/

WORKDIR ${HERMES_HOME}

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gateway", "run"]
