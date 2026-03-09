# Deby Lite - Web3 Compliant AI Agent
# Built on Debian Trixie 13.3 (vs Agent Zero which uses Kali Linux)
FROM debian:trixie

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

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    build-essential gcc g++ cmake pkg-config \
    nodejs npm \
    curl wget git openssh-client procps ca-certificates \
    poppler-utils \
    tesseract-ocr tesseract-ocr-eng \
    libsndfile1 libsndfile1-dev ffmpeg \
    pandoc libmagic1 libmagic-dev \
    libgl1 libglib2.0-0 libjpeg-dev libpng-dev \
    libxml2-dev libxslt1-dev \
    libffi-dev libssl-dev \
    libblas-dev liblapack-dev gfortran \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /deby

# Copy split requirements
COPY requirements-core.txt requirements-heavy.txt ./

# Create venv
RUN python3 -m venv /deby/.venv && \
    pip install --upgrade pip setuptools wheel

# Stage 1: Core dependencies (must succeed)
RUN pip install --no-cache-dir -r requirements-core.txt

# Stage 2: Heavy ML packages with CPU-only torch (saves ~1.5GB)
RUN pip install --no-cache-dir -r requirements-heavy.txt

# Stage 3: Optional packages (each allowed to fail individually)
RUN pip install --no-cache-dir browser-use==0.5.11 || true
RUN pip install --no-cache-dir playwright==1.52.0 && playwright install --with-deps chromium || true
RUN pip install --no-cache-dir kokoro>=0.9.2 || true
RUN pip install --no-cache-dir openai-whisper==20250625 || true
RUN pip install --no-cache-dir langchain-unstructured==0.1.6 || true
RUN pip install --no-cache-dir "unstructured[all-docs]==0.16.23" || true
RUN pip install --no-cache-dir unstructured-client==0.31.0 || true

# Copy application code
COPY . .

# Create required directories
RUN mkdir -p /deby/usr /deby/tmp /deby/logs /deby/knowledge

# Startup
COPY start_deby_lite.sh /start_deby_lite.sh
RUN chmod +x /start_deby_lite.sh

EXPOSE 80

CMD ["/start_deby_lite.sh"]
