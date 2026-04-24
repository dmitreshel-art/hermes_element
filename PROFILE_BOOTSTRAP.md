# Развёртывание профиля Hermes Element Helpdesk

Этот репозиторий уже содержит готовый профиль агента для Docker Compose.

## Основной способ запуска

Используйте Docker Compose:

```bash
cp hermes-home/.env.example hermes-home/.env
# заполнить hermes-home/.env

docker compose -f docker/docker-compose.yml up -d --build
```

## Где находится профиль агента

```text
hermes-home/
```

Эта папка монтируется в контейнер как:

```text
/data
```

То есть внутри контейнера:

```text
HERMES_HOME=/data
```

## Где находится база знаний

Единственная база знаний проекта:

```text
hermes-home/knowledge/
```

Не создавайте вторую копию `knowledge/` в корне репозитория. Если нужно изменить ответы агента, редактируйте файлы только в `hermes-home/knowledge/`.

## Где находится системная инструкция

Hermes использует:

```text
hermes-home/SOUL.md
```

## Где находится RAG-дизайн

```text
hermes-home/RAG_DESIGN.md
```

## Что проверить перед production-запуском

1. В `hermes-home/.env` нет `CHANGE_ME`, `***`, `example.org` и других заглушек.
2. В `hermes-home/config.yaml` выбран нужный провайдер/модель.
3. В `hermes-home/knowledge/` нет шаблонных placeholder-ов.
4. `docker compose -f docker/docker-compose.yml config` проходит без ошибок.
5. Агент сначала тестируется в DM или ограниченной support-комнате.
