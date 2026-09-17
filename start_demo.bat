@echo off
chcp 65001 >nul
echo ===================================================
echo   Speech-to-Speech 即時語音助理 Web Demo 一鍵啟動
echo ===================================================
echo.

cd /d "%~dp0"

echo [1/2] 正在啟動 Web 前端伺服器 (http://localhost:7860)...
start "S2S Web UI" cmd /k ".\.venv\Scripts\python.exe -m uvicorn --app-dir demo server:app --port 7860 --host 0.0.0.0"

echo.
echo [2/2] 請選擇後端啟動方式：
echo   1. 使用 OpenAI API (需輸入 API Key)
echo   2. 使用 DeepSeek API (需輸入 API Key)
echo   3. 使用純本地 CPU 輕量模型 (免 API Key)
echo.
set /p choice="請輸入選項 (1, 2 或 3): "

if "%choice%"=="1" (
    set /p apikey="請輸入您的 OpenAI API Key (sk-...): "
    set OPENAI_API_KEY=%apikey%
    echo 正在啟動語音服務端 (OpenAI)...
    .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend responses-api --tts qwen3 --tts_device cpu
) else if "%choice%"=="2" (
    set /p apikey="請輸入您的 DeepSeek API Key (sk-...): "
    echo 正在啟動語音服務端 (DeepSeek)...
    .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend responses-api --model_name deepseek-chat --responses_api_api_key "%apikey%" --responses_api_base_url "https://api.deepseek.com/v1" --tts qwen3 --tts_device cpu
) else (
    echo 正在啟動純本地輕量模型 (Qwen2.5-0.5B on CPU)...
    .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend transformers --model_name Qwen/Qwen2.5-0.5B-Instruct --tts qwen3 --tts_device cpu
)

pause
