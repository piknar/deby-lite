#!/bin/bash
export A0_ROOT=/deby
export PYTHONPATH=/deby
export VIRTUAL_ENV=/deby/.venv
export PATH="/deby/.venv/bin:$PATH"
export IS_DOCKERIZED=true
export SHELL_INTERFACE=local
export A0_SET_SHELL_INTERFACE=local
export A0_SET_CODE_EXEC_SSH_ENABLED=false

# Initialize required directories and files
mkdir -p /deby/usr /deby/logs /deby/tmp /deby/usr/chats

# Initialize .env if missing
if [ ! -s /deby/usr/.env ] && [ -f /deby/.env ]; then
    cp /deby/.env /deby/usr/.env
    echo "[deby-lite] Initialized /deby/usr/.env from base .env"
elif [ ! -f /deby/usr/.env ]; then
    touch /deby/usr/.env
    echo "[deby-lite] Created empty /deby/usr/.env"
fi

echo "[deby-lite] Starting Agent Zero on 0.0.0.0:8080..."
cd /deby
exec /deby/.venv/bin/python run_ui.py --port 8080 --host 0.0.0.0 --dockerized=true
