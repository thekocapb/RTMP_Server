#!/bin/bash
# Скрипт для отправки тестового потока на SRS сервер
# Генерирует тестовый видеопоток с помощью FFmpeg
# Использование: ./test_stream.sh [server_ip]

SERVER="${1:-localhost}"
STREAM_KEY="stream"

echo "Отправка тестового потока на rtmp://${SERVER}:1935/live/${STREAM_KEY}"
echo "Нажмите Ctrl+C для остановки"
echo ""

# Генерация тестового видео с цветными полосами и таймером
ffmpeg -re \
  -f lavfi -i "testsrc2=duration=3600:size=1280x720:rate=30" \
  -f lavfi -i "sine=frequency=440:duration=3600:sample_rate=44100" \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v 2500k -maxrate 2500k -bufsize 5000k \
  -pix_fmt yuv420p -g 60 \
  -c:a aac -b:a 128k -ar 44100 \
  -f flv "rtmp://${SERVER}:1935/live/${STREAM_KEY}"
