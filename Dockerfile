# Deby Lite - Web3 Compliant AI Agent
# Built on Debian Trixie 13.3 (vs Agent Zero which uses Kali Linux)
FROM debian:trixie-slim

LABEL maintainer="piknar <piknar@gmail.com>"
LABEL description="Deby Lite - Web3 compliant AI agent, fork of Agent Zero"
LABEL org.opencontainers.image.source="https://github.com/piknar/deby-lite"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive
ENV A0_ROOT=/deby
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    nodejs \
    npm \
    chromium \
    chromium-driver \
    ca-certificates \
    openssh-client \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /deby

# Copy application files
COPY requirements.txt .

# Create venv and install Python dependencies
RUN python3 -m venv /deby/.venv && \
    /deby/.venv/bin/pip install --upgrade pip && \
    /deby/.venv/bin/pip install -r requirements.txt

# Copy rest of application
COPY . .

# Create necessary directories
RUN mkdir -p /deby/usr/chats \
    /deby/usr/memory \
    /deby/usr/knowledge \
    /deby/usr/workdir \
    /deby/tmp

# Make startup script executable
RUN chmod +x /deby/start_deby_lite.sh 2>/dev/null || true

EXPOSE 80

# Use venv python
ENV PATH="/deby/.venv/bin:$PATH"

CMD ["bash", "/deby/start_deby_lite.sh"]
