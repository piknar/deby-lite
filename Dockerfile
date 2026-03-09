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

# Install system dependencies in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    build-essential gcc g++ cmake pkg-config \
    nodejs npm \
    curl wget git openssh-client procps ca-certificates \
    # Rust compiler (needed by kokoro and other packages)
    rustc cargo \
    # PDF processing
    poppler-utils \
    # OCR
    tesseract-ocr tesseract-ocr-eng \
    # Audio/Video
    libsndfile1 libsndfile1-dev ffmpeg \
    # Document processing
    pandoc libmagic1 libmagic-dev \
    # Image processing
    libgl1 libglib2.0-0 libjpeg-dev libpng-dev \
    # XML/HTML
    libxml2-dev libxslt1-dev \
    # Crypto/SSL
    libffi-dev libssl-dev \
    # Math libs
    libblas-dev liblapack-dev gfortran \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /deby

# Copy requirements
COPY requirements.txt requirements2.txt ./

# Create venv and install deps in stages for better caching and error visibility
RUN python3 -m venv /deby/.venv && \
    /deby/.venv/bin/pip install --upgrade pip setuptools wheel

# Install core deps first (most likely to succeed)
RUN /deby/.venv/bin/pip install --no-cache-dir \
    flask[async]==3.0.3 flask-basicauth==0.2.0 \
    python-dotenv==1.1.0 pydantic==2.11.7 \
    openai==1.99.5 litellm==1.79.3 \
    python-socketio>=5.14.2 uvicorn>=0.38.0 wsproto>=1.2.0

# Install ML/AI packages (heavy, may need torch)
RUN /deby/.venv/bin/pip install --no-cache-dir \
    faiss-cpu==1.11.0 \
    sentence-transformers==3.0.1 \
    tiktoken==0.8.0

# Install document processing
RUN /deby/.venv/bin/pip install --no-cache-dir \
    pypdf==6.0.0 pymupdf==1.25.3 \
    pytesseract==0.3.13 pdf2image==1.17.0 \
    lxml_html_clean==0.3.1 \
    beautifulsoup4>=4.12.3 html2text>=2024.2.26 \
    markdownify==1.1.0 markdown==3.7 \
    newspaper3k==0.2.8

# Install audio packages
RUN /deby/.venv/bin/pip install --no-cache-dir \
    soundfile==0.13.1 \
    kokoro>=0.9.2 || true

# Install whisper (large download)
RUN /deby/.venv/bin/pip install --no-cache-dir \
    openai-whisper==20250625 || true

# Install remaining packages
RUN /deby/.venv/bin/pip install --no-cache-dir \
    a2wsgi==1.10.8 ansio==0.0.1 \
    browser-use==0.5.11 docker==7.1.0 \
    duckduckgo-search==6.1.12 \
    fastmcp==2.13.1 fasta2a==0.5.0 \
    flaredantic==0.1.5 GitPython==3.1.43 \
    inputimeout==1.0.4 simpleeval==1.0.3 \
    langchain-core==0.3.49 langchain-community==0.3.19 \
    mcp==1.22.0 paramiko==3.5.0 \
    playwright==1.52.0 pytz==2024.2 \
    webcolors==24.6.0 nest-asyncio==1.6.0 \
    crontab==1.0.1 pathspec>=0.12.1 \
    psutil>=7.0.0 imapclient>=3.0.1 \
    boto3>=1.35.0 exchangelib>=5.4.3

# Install unstructured (very heavy, optional)
RUN /deby/.venv/bin/pip install --no-cache-dir \
    langchain-unstructured[all-docs]==0.1.6 \
    unstructured[all-docs]==0.16.23 \
    unstructured-client==0.31.0 || true

# Install Playwright browsers
RUN /deby/.venv/bin/playwright install chromium --with-deps 2>/dev/null || true

# Copy application code
COPY . .

# Create runtime directories
RUN mkdir -p /deby/usr/chats /deby/usr/memory /deby/usr/knowledge \
    /deby/usr/workdir /deby/logs /deby/tmp

RUN chmod +x /deby/start_deby_lite.sh

EXPOSE 8080

CMD ["bash", "/deby/start_deby_lite.sh"]
