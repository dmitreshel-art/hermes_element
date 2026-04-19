#!/usr/bin/env bash
set -euo pipefail

SRC_PROFILE="${1:-/root/.hermes/profiles/element-helpdesk}"
DEST_ROOT="${2:-/root/element-hermes-assistant/docker-gateway/hermes-home}"
HERMES_BIN="/root/.hermes/venv/bin/hermes"

mkdir -p "$DEST_ROOT"
mkdir -p "$DEST_ROOT/home" "$DEST_ROOT/logs" "$DEST_ROOT/sessions" "$DEST_ROOT/knowledge"

cp "$SRC_PROFILE/config.yaml" "$DEST_ROOT/config.yaml"
cp "$SRC_PROFILE/.env" "$DEST_ROOT/.env"
cp "$SRC_PROFILE/SYSTEM_PROMPT.md" "$DEST_ROOT/SYSTEM_PROMPT.md"
cp "$SRC_PROFILE/RAG_DESIGN.md" "$DEST_ROOT/RAG_DESIGN.md"
cp -r "$SRC_PROFILE/knowledge/." "$DEST_ROOT/knowledge/"

# SOUL.md — реально используемый system prompt Hermes внутри отдельного HERMES_HOME.
cp "$SRC_PROFILE/SYSTEM_PROMPT.md" "$DEST_ROOT/SOUL.md"

DEST_ROOT="$DEST_ROOT" python3 - <<'PY'
import os
from pathlib import Path
p = Path(os.environ['DEST_ROOT']) / 'SOUL.md'
text = p.read_text()
extra = '''

## Runtime knowledge lookup for this deployment

Твоя локальная база знаний находится в каталоге `HERMES_HOME/knowledge`.
Если вопрос касается стандартного поведения Element/Matrix, сначала ищи ответ в этих локальных markdown-файлах через file tools.
Особенно важны файлы:
- `knowledge/general-*.md`
- `knowledge/faq-*.md`
- `knowledge/howto-*.md`
- `knowledge/troubleshooting-*.md`
- `knowledge/general-glossary-element-matrix.md`

Когда вопрос тонкий или рискованный:
1. сначала найди релевантный файл в `knowledge/`;
2. затем прочитай нужный фрагмент;
3. затем дай ответ.

Не отвечай по общей части слишком абстрактно, если в `knowledge/` уже есть конкретное объяснение.
'''
if extra not in text:
    p.write_text(text + extra)
PY

# Минимизируем опасные/лишние toolsets в отдельном docker-home.
export HERMES_HOME="$DEST_ROOT"
for toolset in web browser terminal code_execution image_gen delegation cronjob homeassistant messaging tts vision moa todo clarify; do
  "$HERMES_BIN" tools disable "$toolset" >/dev/null || true
done

# Безопасный helpdesk-режим: локальная KB + память + skills + recall прошлых сессий.
"$HERMES_BIN" tools enable file >/dev/null || true
"$HERMES_BIN" tools enable memory >/dev/null || true
"$HERMES_BIN" tools enable skills >/dev/null || true
"$HERMES_BIN" tools enable session_search >/dev/null || true

cat <<EOF
Prepared isolated docker home at: $DEST_ROOT
Source profile: $SRC_PROFILE

Toolset profile:
- enabled: file, memory, skills, session_search
- disabled: terminal, browser, web, code_execution, messaging, delegation, cronjob, homeassistant, vision, image_gen, clarify, todo, tts

Before real launch, verify:
- $DEST_ROOT/.env
- $DEST_ROOT/config.yaml
- $DEST_ROOT/SOUL.md
EOF
