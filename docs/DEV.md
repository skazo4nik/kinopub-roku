# Заметки для разработки

## Структура

- `components/MainScene.*` — маршрутизация, меню, каталог, поиск, плеер, настройки.
- `components/DetailScreen.*` — карточка фильма/сериала.
- `components/AuthScreen.*` — вход по коду.
- `components/ApiTask.*` — запросы к API (токен, обновление при 401, кэш списков, статус сервера).
- `components/lib.brs` — общие функции (запросы, форматирование, выбор потока).

## API kino.pub (что используется)

Документация: <https://kinoapi.com>. Базовый адрес `https://api.service-kp.com`.

| Назначение | Запрос |
|---|---|
| Вход | `POST /oauth2/device` (device_code / device_token), `POST /oauth2/token` |
| Каталог | `GET /v1/items`, `/v1/items/fresh`, `/popular`, `/hot`, `/v1/items/search` |
| Карточка | `GET /v1/items/{id}` (параметр `nolinks=1` убирает ссылки на видео) |
| Я смотрю | `GET /v1/watching/serials?subscribed=1`, `/v1/watching/movies` |
| Отметки | `GET /v1/watching/marktime`, `/v1/watching/toggle`, `/v1/watching/togglewatchlist` |
| Подборки | `GET /v1/collections`, `/v1/collections/view?id=` |
| Закладки | `GET /v1/bookmarks`, `/v1/bookmarks/{id}` |
| Справочники | `GET /v1/genres`, `/v1/countries`, `/v1/types` |
| Заставки | `GET https://arm.haglund.dev/api/v2/imdb?id=tt…` (IMDb → MAL по сезонам), `GET https://api.aniskip.com/v2/skip-times/{mal}/{серия}` |
| Устройство | `GET /v1/device/info`, `POST /v1/device/{id}/settings`, `POST /v1/device/notify` |

Особенности: «изменяющие» запросы в API делаются через GET; 4K — не тип, а фильтр `quality=4k`.

## Отладочные параметры запуска

Через ECP (`POST http://<IP>:8060/launch/dev?...`):

- `section=<id>` — открыть раздел (`home`, `watching`, `k4`, `settings`...)
- `contentId=<id>` — открыть карточку
- `probe=/v1/...` — выполнить запрос и напечатать ответ в консоль (`KPPROBE`, `KPRAW`)
- `autoplay=<id>&season=1&ep=1[&panel=1]` — сразу запустить воспроизведение

В Roku включено ограничение ECP «Limited»: если команды клавиш возвращают 403, разрешите управление мобильными приложениями в настройках Roku.
