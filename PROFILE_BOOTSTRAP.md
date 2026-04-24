# Bootstrap отдельного профиля Hermes для помощника по Element

## Цель

Создать отдельный профиль Hermes, который:
- живёт отдельно от твоего основного ассистента;
- отвечает только на пользовательские вопросы по Element/Matrix;
- использует отдельную базу знаний;
- не имеет лишних админских инструментов.

## Рекомендуемое имя профиля

`element-helpdesk`

## Шаги

### 1. Создай профиль

```bash
/root/.hermes/venv/bin/hermes profile create element-helpdesk
```

### 2. Скопируй шаблоны

```bash
cp /root/element-hermes-assistant/profile-template/config.yaml ~/.hermes/profiles/element-helpdesk/config.yaml
cp /root/element-hermes-assistant/profile-template/.env.example ~/.hermes/profiles/element-helpdesk/.env
```

### 3. Отредактируй `.env`

Заполни:
- Matrix homeserver
- bot user / password или access token
- список разрешённых пользователей
- API key провайдера модели
- при необходимости encryption/recovery key

### 4. Подготовь knowledge base

Минимум заполни:
- `/root/element-hermes-assistant/knowledge/seed-faq.md`
- свои howto по login / notifications / device verification
- свои troubleshooting по login / no notifications / cant decrypt
- свои контакты эскалации

### 5. Подключи системный промпт

Практически лучше хранить его как основной reference-файл владельца профиля:
- `/root/element-hermes-assistant/SYSTEM_PROMPT.md`

Варианты использования:
1. сделать его базовым системным промптом через вашу кастомную интеграцию/обвязку;
2. подмешивать его в startup wrapper при запуске агента;
3. если используешь кастомный launcher для Hermes — передавать этот prompt как system override.

### 6. Ограничь инструменты

Идея для user-support профиля:
- оставить knowledge / file / session_search / clarify при необходимости;
- не давать terminal, browser, admin и опасные инструменты в пользовательский контур.

### 7. Настрой Matrix-канал

Вариант запуска:
- отдельный бот-аккаунт Matrix;
- ответы в DM;
- отдельная комната поддержки при необходимости.

Если делаешь общую комнату, безопаснее:
- thread-by-default;
- не отвечать во всех комнатах подряд;
- ограничить свободные комнаты списком support rooms.

## Рекомендуемая модель работы

### MVP
- бот отвечает только по FAQ, howto и troubleshooting;
- при сомнениях — эскалация в ИТ;
- без самостоятельных действий в инфраструктуре.

### Следующий шаг
- собирать логи unanswered questions;
- раз в неделю обновлять FAQ;
- выделить отдельный owner у knowledge base.

## Что проверить перед запуском

- бот логинится в Matrix;
- бот отвечает в DM;
- бот не отвечает на посторонние вопросы вне темы Element;
- бот не фантазирует про лимиты, политики, права и контакты;
- бот правильно эскалирует темы шифрования/компрометации.
