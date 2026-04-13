# RTMP Server на базе SRS (Simple Realtime Server)

> Форк проекта [SRS (Simple Realtime Server)](https://github.com/ossrs/srs) — высокопроизводительного медиасервера с открытым исходным кодом.

## Что такое SRS?

**SRS (Simple Realtime Server)** — это open-source медиасервер, написанный на C++, который поддерживает:

- **RTMP** — приём и раздача потокового видео (основной протокол для стриминга)
- **HLS** — HTTP Live Streaming для воспроизведения в браузерах и на мобильных устройствах
- **HTTP-FLV** — низколатентная раздача видео по HTTP
- **WebRTC** — сверхнизкая задержка (< 1 сек) для интерактивных сценариев
- **SRT** — Secure Reliable Transport для передачи видео через нестабильные сети
- **MPEG-DASH** — альтернатива HLS для адаптивного стриминга

## Как это работает?

```
┌─────────────┐     RTMP (порт 1935)     ┌─────────────┐
│   OBS/FFmpeg │ ────────────────────────► │  SRS Сервер │
│  (Источник)  │                          │             │
└─────────────┘                          │  Принимает   │
                                          │  RTMP-поток  │
┌─────────────┐     HLS (порт 8080)      │  и раздаёт   │
│   Браузер    │ ◄──────────────────────── │  в разных    │
│   Зритель    │                          │  форматах    │
└─────────────┘                          │             │
                                          │             │
┌─────────────┐     HTTP-FLV (8080)      │             │
│  Плеер FLV  │ ◄──────────────────────── │             │
└─────────────┘                          └─────────────┘
```

### Пошагово:

1. **Источник (encoder)** — OBS Studio, FFmpeg или камера — отправляет видеопоток по протоколу RTMP на сервер (порт `1935`)
2. **SRS принимает поток** — демультиплексирует видео и аудио
3. **SRS раздаёт поток** зрителям в нескольких форматах одновременно:
   - RTMP — для ретрансляции на другие серверы
   - HLS — нарезает поток на `.m3u8` + `.ts` сегменты для браузеров
   - HTTP-FLV — отдаёт непрерывный FLV-поток через HTTP
   - WebRTC — для просмотра с минимальной задержкой

## Быстрый старт

### Способ 1: Docker (рекомендуется)

```bash
# Запуск SRS в контейнере
docker-compose up -d

# Проверка что сервер работает
curl http://localhost:8080
```

### Способ 2: Docker без compose

```bash
docker run -d \
  --name srs-server \
  -p 1935:1935 \
  -p 8080:8080 \
  -p 1985:1985 \
  -p 8000:8000/udp \
  -v $(pwd)/conf/srs.conf:/usr/local/srs/conf/srs.conf \
  ossrs/srs:5
```

### Способ 3: Сборка из исходников (Linux)

```bash
git clone https://github.com/ossrs/srs.git
cd srs/trunk
./configure
make
./objs/srs -c conf/srs.conf
```

## Как отправить поток на сервер

### Через FFmpeg:

```bash
ffmpeg -re -i video.mp4 \
  -c:v libx264 -c:a aac \
  -f flv rtmp://localhost:1935/live/stream
```

### Через OBS Studio:

1. Откройте **Настройки → Трансляция**
2. Сервис: `Пользовательский`
3. Сервер: `rtmp://ВАШ_IP:1935/live`
4. Ключ потока: `stream` (или любой другой)
5. Нажмите **Начать трансляцию**

## Как смотреть поток

| Формат    | URL                                                  | Задержка   |
|-----------|------------------------------------------------------|------------|
| HTTP-FLV  | `http://localhost:8080/live/stream.flv`              | 1-3 сек    |
| HLS       | `http://localhost:8080/live/stream.m3u8`             | 5-30 сек   |
| WebRTC    | `http://localhost:1985/rtc/v1/whep/?app=live&stream=stream` | < 1 сек |

Для просмотра HLS можно открыть встроенный плеер SRS:
```
http://localhost:8080/players/srs_player.html
```

## Структура проекта

```
RTMP_Server/
├── conf/
│   └── srs.conf              # Конфигурация SRS
├── html/
│   └── index.html             # Веб-плеер для просмотра потока
├── docker-compose.yml         # Docker Compose для запуска
├── start.sh                   # Скрипт быстрого запуска
├── test_stream.sh             # Скрипт для тестовой трансляции
└── README.md                  # Этот файл
```

## API управления

SRS предоставляет HTTP API на порту `1985`:

```bash
# Информация о сервере
curl http://localhost:1985/api/v1/versions

# Список активных потоков
curl http://localhost:1985/api/v1/streams/

# Список подключённых клиентов
curl http://localhost:1985/api/v1/clients/

# Статистика VHost
curl http://localhost:1985/api/v1/vhosts/
```

## Порты

| Порт   | Протокол | Назначение                    |
|--------|----------|-------------------------------|
| 1935   | TCP      | RTMP — приём/раздача потоков  |
| 8080   | TCP      | HTTP — HLS, HTTP-FLV, плеер  |
| 1985   | TCP      | HTTP API — управление сервером|
| 8000   | UDP      | WebRTC — сверхнизкая задержка |

## Ссылки

- [SRS GitHub (upstream)](https://github.com/ossrs/srs)
- [SRS Wiki](https://ossrs.io/lts/en-us/docs/v5/doc/introduction)
- [SRS Docker Hub](https://hub.docker.com/r/ossrs/srs)
