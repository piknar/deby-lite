# Deby Lite - Web3 Compliant AI Agent
# Built on Debian Trixie (vs Agent Zero which uses Kali Linux)
FROM debian:trixie

LABEL maintainer="piknar <piknar@gmail.com>"
LABEL description="deby-lite - Agent Zero, lightweight venv, Debian Trixie"
LABEL version="1.0-lite"
LABEL org.opencontainers.image.source="https://github.com/piknar/deby-lite"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies (including Playwright/Chromium browser libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.13 \
    python3.13-venv \
    python3.13-dev \
    python3-pip \
    build-essential \
    gcc \
    g++ \
    pkg-config \
    git \
    curl \
    wget \
    ca-certificates \
    bash \
    procps \
    htop \
    nano \
    unzip \
    zip \
    tar \
    rsync \
    jq \
    libxml2-dev \
    libxslt1-dev \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgtk-3-0 \
    fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /deby

# Create venv with Python 3.13
RUN python3.13 -m venv /deby/.venv && \
    /deby/.venv/bin/pip install --upgrade pip setuptools wheel

# Copy application code
COPY . /deby/

# Install all dependencies from single requirements file
COPY requirements_lite.txt /tmp/requirements_lite.txt
RUN /deby/.venv/bin/pip install --no-cache-dir -r /tmp/requirements_lite.txt

# Set environment variables
ENV A0_ROOT=/deby
ENV PYTHONPATH=/deby
ENV VIRTUAL_ENV=/deby/.venv
ENV PATH="/deby/.venv/bin:$PATH"
ENV IS_DOCKERIZED=true
ENV SHELL_INTERFACE=local
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Startup script
COPY start_deby_lite.sh /start_deby_lite.sh
RUN chmod +x /start_deby_lite.sh

EXPOSE 8080

ENTRYPOINT ["/start_deby_lite.sh"]
