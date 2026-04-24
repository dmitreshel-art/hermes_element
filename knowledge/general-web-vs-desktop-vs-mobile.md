---
source_id: general-platform-differences-001
title: Общая справка: чем отличаются Element Web, Desktop и Mobile
doc_type: faq
product_area: mobile
audience: employee
platform: all
criticality: normal
version: 0.1
updated_at: 2026-04-17
authoritative: true
source_type: synthesized_from_official_docs
source_url: https://docs.element.io/latest/element-support/element-webdesktop-client-settings/notification-settings/
---

# Общая справка: чем отличаются Element Web, Desktop и Mobile

## Главное различие
Хотя пользователь видит "один и тот же аккаунт", Element Web, Desktop и Mobile на практике могут вести себя как разные клиентские сессии.

Это важно для:
- уведомлений;
- списка sessions;
- device verification;
- доступа к зашифрованной истории;
- локальных настроек конкретного клиента.

## Что полезно объяснять пользователю
- web-клиент в браузере и desktop-приложение на одном компьютере могут отображаться как разные sessions;
- мобильный клиент может иметь своё отдельное поведение по push-уведомлениям;
- часть настроек аккаунта синхронизируется, а часть привязана к конкретному устройству/клиенту.

## Что это значит practically
### Если проблема только в web
Это не обязательно значит, что сломан весь аккаунт.

### Если проблема только в mobile
Это может быть не ошибка Matrix в целом, а вопрос push-разрешений, батареи, platform-specific клиента или конкретной мобильной сессии.

### Если проблема только в desktop
Иногда проще проверить, воспроизводится ли она в web-клиенте, чтобы понять, это account-level проблема или client-level.

## Хороший общий совет
При диагностике всегда полезно уточнять:
- какой именно клиент используется;
- воспроизводится ли проблема в другом клиенте;
- касается ли проблема одной конкретной session или всего аккаунта.
