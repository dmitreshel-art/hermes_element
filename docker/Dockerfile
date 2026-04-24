FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HERMES_HOME=/data

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    git \
    curl \
    libolm-dev \
    libffi-dev \
    pkg-config \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install Hermes with Matrix + CLI support directly from upstream source.
# This keeps the deploy bundle self-contained without committing Hermes source.
RUN pip install --upgrade pip setuptools wheel && \
    pip install "hermes-agent[matrix,cli] @ git+https://github.com/NousResearch/hermes-agent.git"

WORKDIR /data
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["hermes", "gateway", "run"]
