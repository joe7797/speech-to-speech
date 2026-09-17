@echo off
chcp 65001 >nul
echo ===================================================
echo   Speech-to-Speech 即時語音助理 Web Demo 一鍵啟動
echo ===================================================
echo.

cd /d "%~dp0"

if exist .env (
    for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
        set "%%A=%%B"
    )
)

echo [1/2] 正在啟動 Web 前端伺服器 (http://localhost:7860)...
set SPEECH_TO_SPEECH_URL=ws://127.0.0.1:8765/v1/realtime
start "S2S Web UI" cmd /k "set SPEECH_TO_SPEECH_URL=ws://127.0.0.1:8765/v1/realtime && .\.venv\Scripts\python.exe -m uvicorn --app-dir demo server:app --port 7860 --host 0.0.0.0"

echo.
echo [2/2] 請選擇後端啟動方式：
echo   1. 使用 Google Gemini 3.6 Flash (直接按 Enter 即可)
echo   2. 使用 OpenAI / DeepSeek API
echo   3. 使用純本地 CPU 輕量模型 (免 API Key)
echo.
set /p choice="請輸入選項 (預設 1): "
if "%choice%"=="" set choice=1

if "%choice%"=="1" (
    if "%GEMINI_API_KEY%"=="" (
        set /p GEMINI_API_KEY="請輸入您的 Gemini API Key: "
    )
    echo 正在啟動語音服務端 (Google Gemini 3.6 Flash)...
    .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend chat-completions --model_name gemini-3.6-flash --responses_api_base_url "https://generativelanguage.googleapis.com/v1beta/openai/" --responses_api_api_key "%GEMINI_API_KEY%" --tts facebookMMS --facebook_mms_device cpu
) else if "%choice%"=="2" (
    set /p apikey="請輸入您的 API Key (sk-...): "
    set /p baseurl="請輸入 Base URL (直接按 Enter 預設為 OpenAI): "
    if "%baseurl%"=="" (
        .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend responses-api --responses_api_api_key "%apikey%" --tts facebookMMS --facebook_mms_device cpu
    ) else (
        .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend chat-completions --model_name deepseek-chat --responses_api_base_url "%baseurl%" --responses_api_api_key "%apikey%" --tts facebookMMS --facebook_mms_device cpu
    )
) else (
    echo 正在啟動純本地輕量模型 (Qwen2.5-0.5B on CPU)...
    .\.venv\Scripts\speech-to-speech.exe serve --host 0.0.0.0 --port 8765 --stt parakeet-tdt --llm_backend transformers --model_name Qwen/Qwen2.5-0.5B-Instruct --tts facebookMMS --facebook_mms_device cpu
)

pause
