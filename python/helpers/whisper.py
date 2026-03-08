import base64
import warnings
import tempfile
import asyncio
from python.helpers import runtime, rfc, settings, files
from python.helpers.print_style import PrintStyle
from python.helpers.notification import NotificationManager, NotificationType, NotificationPriority

# Optional whisper import - gracefully disabled if not installed
try:
    import whisper as _whisper_module
    WHISPER_AVAILABLE = True
except ImportError:
    _whisper_module = None
    WHISPER_AVAILABLE = False

# Suppress FutureWarning from torch.load
warnings.filterwarnings("ignore", category=FutureWarning)

_model = None
_model_name = ""
is_updating_model = False

async def preload(model_name:str):
    if not WHISPER_AVAILABLE:
        return
    try:
        return await _preload(model_name)
    except Exception as e:
        raise e

async def _preload(model_name:str):
    global _model, _model_name, is_updating_model
    if not WHISPER_AVAILABLE:
        return
    while is_updating_model:
        await asyncio.sleep(0.1)
    try:
        is_updating_model = True
        if not _model or _model_name != model_name:
            NotificationManager.send_notification(
                NotificationType.INFO, NotificationPriority.NORMAL,
                "Loading Whisper model...", display_time=99, group="whisper-preload")
            PrintStyle.standard(f"Loading Whisper model: {model_name}")
            _model = _whisper_module.load_model(name=model_name, download_root=files.get_abs_path("/tmp/models/whisper"))
            _model_name = model_name
            NotificationManager.send_notification(
                NotificationType.INFO, NotificationPriority.NORMAL,
                "Whisper model loaded.", display_time=2, group="whisper-preload")
    finally:
        is_updating_model = False

async def is_downloading():
    return _is_downloading()

def _is_downloading():
    return is_updating_model

async def is_downloaded():
    try:
        return _is_downloaded()
    except Exception as e:
        raise e

def _is_downloaded():
    return _model is not None

async def transcribe(model_name:str, audio_bytes_b64: str):
    return await _transcribe(model_name, audio_bytes_b64)

async def _transcribe(model_name:str, audio_bytes_b64: str):
    if not WHISPER_AVAILABLE:
        raise RuntimeError("Whisper not available in deby-lite. Install openai-whisper to enable.")
    await _preload(model_name)
    audio_bytes = base64.b64decode(audio_bytes_b64)
    import os
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as audio_file:
        audio_file.write(audio_bytes)
        temp_path = audio_file.name
    try:
        result = _model.transcribe(temp_path, fp16=False)
        return result
    finally:
        try:
            os.remove(temp_path)
        except Exception:
            pass
