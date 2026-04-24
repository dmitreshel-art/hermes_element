#!/usr/bin/env bash
set -euo pipefail

# Prepare an isolated HERMES_HOME for Docker/local testing.
# The canonical KB lives in the project-level knowledge/ directory; the Docker
# home receives a synchronized runtime copy.

SRC_PROFILE="${1:-}"
DEST_ROOT="${2:-}"
HERMES_BIN="${HERMES_BIN:-/root/.hermes/venv/bin/hermes}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CANONICAL_KB="$PROJECT_ROOT/knowledge"

if [[ -z "$DEST_ROOT" ]]; then
  DEST_ROOT="$PROJECT_ROOT/hermes-home"
fi

if [[ ! -d "$CANONICAL_KB" ]]; then
  echo "ERROR: canonical knowledge directory not found: $CANONICAL_KB" >&2
  exit 1
fi

mkdir -p "$DEST_ROOT" "$DEST_ROOT/home" "$DEST_ROOT/logs" "$DEST_ROOT/sessions" "$DEST_ROOT/knowledge"

if [[ -n "$SRC_PROFILE" ]]; then
  cp "$SRC_PROFILE/config.yaml" "$DEST_ROOT/config.yaml"
  cp "$SRC_PROFILE/.env" "$DEST_ROOT/.env"
  cp "$SRC_PROFILE/SYSTEM_PROMPT.md" "$DEST_ROOT/SYSTEM_PROMPT.md"
  cp "$SRC_PROFILE/RAG_DESIGN.md" "$DEST_ROOT/RAG_DESIGN.md"
  cp "$SRC_PROFILE/SYSTEM_PROMPT.md" "$DEST_ROOT/SOUL.md"
else
  PROJECT_HOME="$PROJECT_ROOT/hermes-home"
  if [[ "$DEST_ROOT" != "$PROJECT_HOME" ]]; then
    cp "$PROJECT_HOME/config.yaml" "$DEST_ROOT/config.yaml"
    cp "$PROJECT_HOME/SYSTEM_PROMPT.md" "$DEST_ROOT/SYSTEM_PROMPT.md"
    cp "$PROJECT_HOME/RAG_DESIGN.md" "$DEST_ROOT/RAG_DESIGN.md"
    cp "$PROJECT_HOME/SOUL.md" "$DEST_ROOT/SOUL.md"
  fi
  if [[ -f "$PROJECT_HOME/.env.example" && ! -f "$DEST_ROOT/.env" ]]; then
    cp "$PROJECT_HOME/.env.example" "$DEST_ROOT/.env"
  fi
fi

# Runtime KB mirror: always comes from the canonical project-level KB.
rm -rf "$DEST_ROOT/knowledge"
mkdir -p "$DEST_ROOT/knowledge"
cp -a "$CANONICAL_KB/." "$DEST_ROOT/knowledge/"

DEST_ROOT="$DEST_ROOT" python3 - <<'PY'
import os
from pathlib import Path
p = Path(os.environ['DEST_ROOT']) / 'SOUL.md'
text = p.read_text(encoding='utf-8')
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
    p.write_text(text + extra, encoding='utf-8')
PY

if [[ -x "$HERMES_BIN" ]]; then
  export HERMES_HOME="$DEST_ROOT"
  for toolset in web browser terminal code_execution image_gen delegation cronjob homeassistant messaging tts vision moa todo clarify session_search; do
    "$HERMES_BIN" tools disable "$toolset" >/dev/null || true
  done

  # Safe user-facing helpdesk mode: local KB + compact memory + skills.
  "$HERMES_BIN" tools enable file >/dev/null || true
  "$HERMES_BIN" tools enable memory >/dev/null || true
  "$HERMES_BIN" tools enable skills >/dev/null || true
else
  echo "WARN: hermes binary not found at $HERMES_BIN; skipped toolset hardening" >&2
fi

cat <<EOF
Prepared isolated docker/test home at: $DEST_ROOT
Canonical knowledge source: $CANONICAL_KB
Source profile: ${SRC_PROFILE:-project defaults}

Toolset profile:
- enabled: file, memory, skills
- disabled: terminal, browser, web, code_execution, messaging, delegation, cronjob, homeassistant, vision, image_gen, clarify, todo, tts, session_search

Before real launch, verify:
- $DEST_ROOT/.env
- $DEST_ROOT/config.yaml
- $DEST_ROOT/SOUL.md
- $DEST_ROOT/knowledge/
EOF
