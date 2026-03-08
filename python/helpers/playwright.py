import os
import sys
from pathlib import Path
import subprocess
from python.helpers import files

DBG = '/tmp/playwright_debug.log'

def _log(msg):
    with open(DBG, 'a') as f:
        f.write(msg + '\n')

def get_playwright_binary():
    pw_cache = Path(get_playwright_cache_dir())
    _log(f'get_playwright_binary: cache={pw_cache} exists={pw_cache.exists()}')
    if pw_cache.exists():
        _log(f'cache contents: {list(pw_cache.iterdir())}')
    for pattern in (
        "chromium_headless_shell-*/chrome-*/headless_shell",
        "chromium_headless_shell-*/chrome-*/headless_shell.exe",
        "chromium_headless_shell-*/chrome-*/chrome-headless-shell",
        "chromium_headless_shell-*/chrome-*/chrome-headless-shell.exe",
    ):
        binary = next(pw_cache.glob(pattern), None)
        _log(f'pattern={pattern} result={binary}')
        if binary:
            return binary
    return None

def get_playwright_cache_dir():
    cache = files.get_abs_path("tmp/playwright")
    _log(f'get_playwright_cache_dir: {cache}')
    return cache

def ensure_playwright_binary():
    _log('ensure_playwright_binary called')
    _log(f'cwd={os.getcwd()} sys.path={sys.path[:3]}')
    bin = get_playwright_binary()
    if not bin:
        cache = get_playwright_cache_dir()
        _log(f'Binary not found, installing to {cache}')
        env = os.environ.copy()
        env["PLAYWRIGHT_BROWSERS_PATH"] = cache
        subprocess.check_call(
            ["playwright", "install", "chromium", "--only-shell"],
            env=env
        )
    bin = get_playwright_binary()
    if not bin:
        _log('FATAL: Binary not found after installation!')
        raise Exception("Playwright binary not found after installation")
    _log(f'SUCCESS: binary={bin}')
    return bin
