# Hermes Element Helpdesk Assistant

Готовый Docker Compose bundle для пользовательского помощника по служебному мессенджеру Element/Matrix.

## Структура репозитория

```text
docker/
  Dockerfile
  docker-compose.yml
  entrypoint.sh

hermes-home/
  config.yaml
  .env.example
  SOUL.md
  RAG_DESIGN.md
  knowledge/
```

## Источник истины

В репозитории есть **только одна база знаний**:

```text
hermes-home/knowledge/
```

Именно её нужно редактировать при изменении FAQ, how-to, troubleshooting и локальных правил.

Системная инструкция агента:

```text
hermes-home/SOUL.md
```

Документ по устройству RAG/knowledge base:

```text
hermes-home/RAG_DESIGN.md
```

## Быстрый запуск через Docker Compose

1. Скопировать пример окружения:

```bash
cp hermes-home/.env.example hermes-home/.env
```

2. Заполнить `hermes-home/.env`:

- `MATRIX_HOMESERVER`
- `MATRIX_USER_ID` / `MATRIX_PASSWORD` или `MATRIX_ACCESS_TOKEN`
- `MATRIX_ALLOWED_USERS`
- ключ провайдера модели, если он нужен выбранному провайдеру

3. Проверить/изменить `hermes-home/config.yaml`.

4. Запустить:

```bash
docker compose -f docker/docker-compose.yml up -d --build
```

5. Посмотреть логи:

```bash
docker compose -f docker/docker-compose.yml logs -f
```

6. Остановить:

```bash
docker compose -f docker/docker-compose.yml down
```

## Как Docker видит профиль агента

`docker/docker-compose.yml` монтирует профиль целиком:

```yaml
volumes:
  - ../hermes-home:/data
```

В контейнере:

```text
HERMES_HOME=/data
/data/SOUL.md
/data/config.yaml
/data/knowledge/
```

## Роль агента

Агент помогает конечным пользователям:

- вход и первичная настройка Element;
- комнаты, уведомления, устройства, ключи, шифрование;
- базовые правила использования рабочего мессенджера;
- эскалация в поддержку/ИБ, если нужен специалист.

Агент не должен:

- выдумывать настройки, которых нет в локальной базе знаний;
- выдавать себя за администратора;
- принимать пароли, recovery key, access token или другие секреты;
- раскрывать admin-only URL, маршруты и технические endpoints;
- советовать рискованный reset ключей или Secure Backup без предупреждения.

## Проверки перед запуском

```bash
# В репозитории должна быть только одна папка knowledge
find . -type d -name knowledge

# Проверка Docker Compose
 docker compose -f docker/docker-compose.yml config
```

Ожидаемая папка знаний:

```text
./hermes-home/knowledge
```
