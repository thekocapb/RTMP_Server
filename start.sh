#!/bin/bash
# Скрипт быстрого запуска SRS RTMP Server
# Использование: ./start.sh

set -e

echo "==================================="
echo "  SRS RTMP Server — Быстрый старт"
echo "==================================="

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен."
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Проверка docker-compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "Ошибка: docker-compose не найден."
    exit 1
fi

echo ""
echo "Запуск SRS сервера..."
$COMPOSE_CMD up -d

echo ""
echo "Сервер запущен!"
echo ""
echo "Порты:"
echo "  RTMP:    rtmp://localhost:1935"
echo "  HTTP:    http://localhost:8080"
echo "  API:     http://localhost:1985"
echo "  WebRTC:  udp://localhost:8000"
echo ""
echo "Отправка потока через FFmpeg:"
echo "  ffmpeg -re -i video.mp4 -c:v libx264 -c:a aac -f flv rtmp://localhost:1935/live/stream"
echo ""
echo "Просмотр:"
echo "  HLS:      http://localhost:8080/live/stream.m3u8"
echo "  HTTP-FLV: http://localhost:8080/live/stream.flv"
echo "  Плеер:    http://localhost:8080/custom/index.html"
echo ""
echo "Остановка: $COMPOSE_CMD down"
