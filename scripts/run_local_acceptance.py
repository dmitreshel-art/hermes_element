#!/root/.hermes/venv/bin/python3
import os, re, json, time, subprocess
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed

QFILE = '/root/element-hermes-assistant/docker-gateway/hermes-home/knowledge/acceptance-test-questions.md'
HERMES_HOME = '/root/element-hermes-assistant/docker-gateway/hermes-home'
WORKDIR = '/root/element-hermes-assistant/docker-gateway'
HERMES = '/root/.hermes/venv/bin/hermes'
MAX_TURNS = '8'
WORKERS = 4
OUTDIR = '/root/element-hermes-assistant/docker-gateway/reports'

with open(QFILE, 'r', encoding='utf-8') as f:
    content = f.read()
questions = []
section = None
for line in content.splitlines():
    msec = re.match(r'^\s*##\s+(.*)', line)
    if msec:
        section = msec.group(1).strip()
        continue
    m = re.match(r'^\s*(\d+)\.\s+(.*)', line)
    if m:
        questions.append({'num': int(m.group(1)), 'section': section, 'question': m.group(2).strip()})
run_questions = [q for q in questions if q['num'] <= 24]

criteria = {
    1: dict(must_any=['логин', 'пароль', 'matrix.22brn.ru', 'vpn', 'локальн', 'источник'], should_any=['web', 'desktop', 'mobile', 'sso']),
    2: dict(must_any=['sso', 'ошиб'], should_any=['браузер', 'поддержк', 'время']),
    3: dict(must_any=['vpn'], should_any=['поддерж', 'источник', 'не нужен', 'не требуется']),
    4: dict(must_any=['личн', 'можно', 'телефон', 'byod'], should_any=['боту', 'поддерж', 'служебн', 'учётн', 'vpn']),
    5: dict(must_any=['упомин', 'mention'], should_any=['комнат', 'настройк']),
    6: dict(must_any=['android', 'уведом'], should_any=['разреш', 'батар', 'систем']),
    7: dict(must_any=['комнат', 'уведом'], should_any=['настройк', 'mute', 'отключ']),
    8: dict(must_any=['комнат'], should_any=['поиск', 'каталог', 'простран']),
    9: dict(must_any=['комнат', 'пространств'], should_any=['разниц', 'структур']),
    10: dict(must_any=['тред', 'общ'], should_any=['когда', 'если']),
    11: dict(must_any=['комнат', 'созда'], should_any=['локальн', 'политик', 'боту', 'если']),
    12: dict(must_any=['внешн', 'участ'], should_any=['локальн', 'политик', 'нет', 'поддерж']),
    13: dict(must_any=['файл'], should_any=['вложен', 'кнопк', 'перетащ', 'чат']),
    14: dict(must_any=['лимит', 'вложен'], should_any=['не подтвержден', 'источник', 'локальн']),
    15: dict(must_any=['конфиденц', 'чувствит'], should_any=['не отправл', 'уточн', 'иб', 'поддерж', 'локальн', 'политик']),
    16: dict(must_any=['звон'], should_any=['локальн', 'клиент', 'разрешен', 'камера', 'микрофон']),
    17: dict(must_any=['устрой', 'подтверд', 'вериф'], should_any=['локальн', 'процедур', 'ключ']),
    18: dict(must_any=['стар', 'сообщен', 'новом'], should_any=['шифр', 'recovery', 'ключ', 'истор']),
    19: dict(must_any=['незнаком', 'сесси'], should_any=['иб', 'безопас', 'выйти', 'парол']),
    20: dict(must_any=['сброс', 'ключ'], should_any=['риск', 'не стоит', 'останов', 'эскал']),
    21: dict(must_any=['список', 'устрой'], should_any=['сесс', 'настройк']),
    22: dict(must_any=['поддерж', 'инструкц', 'боту'], should_any=['обращ', 'если не помогло', 'напишите']),
    23: dict(must_any=['скрин', 'ошиб', 'верси', 'устрой'], should_any=['время', 'описан']),
    24: dict(must_any=['иб', 'поддерж'], should_any=['взлом', 'незнаком', 'чувствит']),
}

BAD_TOKENS = ['element_web_url','support_contact','security_contact','allowed_clients','login_method','vpn_required','second_factor_method','room_creation_policy','byod_policy','howto_verify_device_doc']

def run_question(q):
    env = os.environ.copy()
    env['HERMES_HOME'] = HERMES_HOME
    cmd = [HERMES, 'chat', '-q', q['question'], '-Q', '--max-turns', MAX_TURNS]
    t0 = time.time()
    p = subprocess.run(cmd, cwd=WORKDIR, env=env, capture_output=True, text=True, timeout=240)
    dt = round(time.time() - t0, 2)
    out = (p.stdout or p.stderr or '').strip()
    ans = out.split('\n', 1)[1].strip() if out.startswith('session_id:') and '\n' in out else out
    lower = ans.lower()
    rule = criteria[q['num']]
    must_hits = [k for k in rule['must_any'] if k.lower() in lower]
    should_hits = [k for k in rule['should_any'] if k.lower() in lower]
    bad_signals = [bad for bad in BAD_TOKENS if bad in lower]
    if p.returncode != 0:
        verdict = 'FAIL'
    elif bad_signals:
        verdict = 'FAIL'
    elif not must_hits:
        verdict = 'FAIL'
    elif should_hits:
        verdict = 'PASS'
    else:
        verdict = 'PARTIAL'
    return {**q, 'elapsed_sec': dt, 'exit_code': p.returncode, 'answer': ans, 'must_hits': must_hits, 'should_hits': should_hits, 'bad_signals': bad_signals, 'verdict': verdict}

results = []
with ThreadPoolExecutor(max_workers=WORKERS) as ex:
    future_map = {ex.submit(run_question, q): q for q in run_questions}
    for fut in as_completed(future_map):
        results.append(fut.result())
results.sort(key=lambda x: x['num'])

quality_checks = []
def add_check(num, title, passed, evidence):
    quality_checks.append({'num': num, 'title': title, 'verdict': 'PASS' if passed else 'FAIL', 'evidence': evidence})

q14 = next(r for r in results if r['num']==14)
add_check(25, 'Не выдумывает точные лимиты на вложения', len(q14['bad_signals'])==0 and any(x in q14['answer'].lower() for x in ['не подтверж', 'в доступных мне источниках', 'точный лимит', 'не зафиксирован']), q14['answer'][:300])
enc = [r for r in results if r['num'] in (17,18,19,20)]
enc_ok = sum(1 for r in enc if any(x in r['answer'].lower() for x in ['риск', 'останов', 'не спеш', 'не рекоменд', 'иб', 'безопас', 'recovery', 'ключ'])) >= 3
add_check(26, 'Предупреждает о рисках в темах ключей и шифрования', enc_ok, ' / '.join(f"Q{r['num']}={r['verdict']}" for r in enc))
esc_count = sum(1 for r in results if any(x in r['answer'].lower() for x in ['если не помогло', 'обрат', 'поддерж', 'иб']) and any(x in r['answer'].lower() for x in ['что сделать', 'проверь', 'открой', 'зайдите', 'включите']))
add_check(27, 'Разделяет self-service шаги и эскалацию', esc_count >= 8, f'{esc_count} ответов содержат и шаги, и эскалацию')
local_count = sum(1 for r in results if any(x in r['answer'].lower() for x in ['локальн', 'в доступных мне источниках', 'не подтвержден', 'точная корпоративная инструкция', 'у вас в компании', 'matrix.22brn.ru', 'этому боту', 'рабочий логин', 'вход через sso не требуется']))
add_check(28, 'Ссылается на локальные правила/ограничения или честно признаёт их отсутствие', local_count >= 6, f'{local_count} ответов с локальным контекстом')

verdict_counts = Counter(r['verdict'] for r in results)
section_counts = defaultdict(lambda: Counter())
section_order = []
for r in results:
    section_counts[r['section']][r['verdict']] += 1
    if r['section'] not in section_order:
        section_order.append(r['section'])

md = []
md.append('# Локальная приёмка Hermes-помощника по Element')
md.append('')
md.append(f'- Дата: {time.strftime("%Y-%m-%d %H:%M:%S")}')
md.append(f'- HERMES_HOME: `{HERMES_HOME}`')
md.append(f'- Команда: `{HERMES} chat -q ... -Q --max-turns {MAX_TURNS}`')
md.append(f'- Потоков: {WORKERS}')
md.append(f'- Всего вопросов: {len(results)}')
md.append(f'- PASS: {verdict_counts.get("PASS",0)}, PARTIAL: {verdict_counts.get("PARTIAL",0)}, FAIL: {verdict_counts.get("FAIL",0)}')
md.append('')
md.append('## Сводка по разделам')
md.append('')
md.append('| Раздел | PASS | PARTIAL | FAIL |')
md.append('|---|---:|---:|---:|')
for sec in section_order:
    c = section_counts[sec]
    md.append(f"| {sec} | {c.get('PASS',0)} | {c.get('PARTIAL',0)} | {c.get('FAIL',0)} |")
md.append('')
md.append('## Глобальные проверки качества')
md.append('')
for qc in quality_checks:
    md.append(f"- Q{qc['num']}: **{qc['verdict']}** — {qc['title']}. {qc['evidence']}")
md.append('')
md.append('## Детальные результаты')
md.append('')
for r in results:
    md.append(f"### Q{r['num']}. {r['question']}")
    md.append(f"- Раздел: {r['section']}")
    md.append(f"- Вердикт: **{r['verdict']}**")
    md.append(f"- Время: {r['elapsed_sec']} сек")
    if r['bad_signals']:
        md.append(f"- Найдены шаблонные токены в ответе: `{', '.join(r['bad_signals'])}`")
    md.append(f"- Попадания по критериям: must={r['must_hits']}, should={r['should_hits']}")
    md.append('- Ответ:')
    md.append('```')
    md.append(r['answer'][:4000])
    md.append('```')
    md.append('')

os.makedirs(OUTDIR, exist_ok=True)
ts = time.strftime('%Y%m%d_%H%M%S')
md_path = os.path.join(OUTDIR, f'acceptance_local_{ts}.md')
json_path = os.path.join(OUTDIR, f'acceptance_local_{ts}.json')
with open(md_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(md))
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump({'results': results, 'quality_checks': quality_checks}, f, ensure_ascii=False, indent=2)
print(json.dumps({'md_report': md_path, 'json_report': json_path, 'summary': dict(verdict_counts), 'quality_checks': quality_checks}, ensure_ascii=False, indent=2))
