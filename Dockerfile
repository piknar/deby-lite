# Deby Lite - Web3 Compliant AI Agent
# Built on Debian Trixie 13.3 (vs Agent Zero which uses Kali Linux)
FROM debian:trixie-slim

LABEL maintainer="piknar <piknar@gmail.com>"
LABEL description="Deby Lite - Web3 compliant AI agent, fork of Agent Zero"
LABEL org.opencontainers.image.source="https://github.com/piknar/deby-lite"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive
ENV A0_ROOT=/deby
ENV PYTHONPATH=/deby
ENV PYTHONUNBUFFERED=1
ENV PATH="/deby/.venv/bin:$PATH"
ENV VIRTUAL_ENV=/deby/.venv
ENV IS_DOCKERIZED=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # Build tools
    build-essential \
    gcc \
    g++ \
    cmake \
    pkg-config \
    # Node.js
    nodejs \
    npm \
    # Browser
    chromium \
    chromium-driver \
    # Network & utils
    curl \
    wget \
    git \
    openssh-client \
    procps \
    ca-certificates \
    # PDF processing
    poppler-utils \
    # OCR
    tesseract-ocr \
    tesseract-ocr-eng \
    # Audio
    libsndfile1 \
    libsndfile1-dev \
    ffmpeg \
    # Document processing
    pandoc \
    libmagic1 \
    libmagic-dev \
    # Image processing
    libgl1 \
    libglib2.0-0 \
    # XML/HTML
    libxml2-dev \
    libxslt1-dev \
    # Misc libs
    libjpeg-dev \
    libpng-dev \
    libffi-dev \
    libssl-dev \
    libblas-dev \
    liblapack-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /deby

# Copy requirements first for layer caching
COPY requirements.txt .

# Create venv and install Python dependencies
RUN python3 -m venv /deby/.venv && \
    /deby/.venv/bin/pip install --upgrade pip setuptools wheel && \
    /deby/.venv/bin/pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers
RUN /deby/.venv/bin/playwright install chromium --with-deps 2>/dev/null || true

# Copy rest of application
COPY . .

# Create necessary runtime directories
RUN mkdir -p /deby/usr/chats \
    /deby/usr/memory \
    /deby/usr/knowledge \
    /deby/usr/workdir \
    /deby/logs \
    /deby/tmp

# Make startup script executable
RUN chmod +x /deby/start_deby_lite.sh

EXPOSE 8080

CMD ["bash", "/deby/start_deby_lite.sh"]
