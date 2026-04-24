# Element Helpdesk KB Cleanup Implementation Plan

> **For Hermes:** This plan is being implemented directly in the current session. Use it as the audit trail for the KB cleanup.

**Goal:** Make the project repository contain the current, production-ready Element helpdesk knowledge base, remove template leftovers/placeholders, and push the corrected state to GitHub.

**Architecture:** The canonical source of truth for user-facing knowledge will be the top-level `knowledge/` directory in the project repository. `hermes-home/knowledge/` remains a runtime/deployment copy for Docker/Hermes tests and must be byte-identical to `knowledge/` after cleanup. Docker runtime artifacts and test sessions are not treated as authoritative knowledge.

**Tech Stack:** Markdown/YAML knowledge files, Bash helper scripts, Git/GitHub.

---

### Task 1: Confirm repository and baseline

**Objective:** Ensure work is done in the pushed Git repository, not only in the temporary Docker test directory.

**Files:**
- Inspect: `/tmp/hermes_element_push`
- Inspect: `git remote -v`
- Inspect: `git status -sb`

**Steps:**
1. Fetch `origin/main`.
2. Confirm branch is `main` and local branch is not behind.
3. Confirm remote is `git@github.com:dmitreshel-art/hermes_element.git`.

**Verification:** `git rev-list --left-right --count HEAD...origin/main` returns `0 0` before changes.

---

### Task 2: Restore canonical top-level `knowledge/`

**Objective:** Put the actual KB in the project folder, not only under Docker test runtime home.

**Files:**
- Create/Update: `knowledge/*.md`
- Create/Update: `knowledge/intent-catalog.yaml`
- Reference source: `hermes-home/knowledge/*`

**Steps:**
1. Copy the current best known KB from `hermes-home/knowledge/` to top-level `knowledge/`.
2. Treat top-level `knowledge/` as canonical.
3. After every KB edit, sync top-level `knowledge/` back to `hermes-home/knowledge/`.

**Verification:** `diff -qr knowledge hermes-home/knowledge` returns no differences.

---

### Task 3: Replace first-login template with real local procedure

**Objective:** Remove the template text from `howto-first-login.md` and replace it with a user-facing instruction consistent with local facts.

**Files:**
- Modify: `knowledge/howto-first-login.md`
- Mirror: `hermes-home/knowledge/howto-first-login.md`

**Content requirements:**
- Server: `matrix.22brn.ru`
- Login method: ordinary work login/password
- VPN: not required for normal Element login
- Separate 2FA: not used in the current scenario
- Clients: web/desktop/mobile, but do not invent a specific web URL unless confirmed
- First-login checks: rooms, notifications, sessions/devices
- Safe warning about device verification/recovery key
- Escalation: write to this bot with error text/screenshot, client/platform/version

**Verification:** No line containing `Замените`, `Рекомендуемый состав`, raw template wording, or contradictory SSO/VPN requirements remains.

---

### Task 4: Replace encrypted-history troubleshooting template

**Objective:** Remove the template text from `troubleshooting-cant-decrypt.md` and create a safe local troubleshooting playbook.

**Files:**
- Modify: `knowledge/troubleshooting-cant-decrypt.md`
- Mirror: `hermes-home/knowledge/troubleshooting-cant-decrypt.md`

**Content requirements:**
- Explain likely causes: new/unverified device, missing keys, no Secure Backup/recovery access
- Safe checks: old trusted device, device verification, recovery key/Secure Backup if already available
- Explicit “do not” list: do not reset Secure Backup/identity/keys casually; do not send recovery keys to bot
- Escalation trigger: if old history matters or reset is offered
- What to attach: platform, client version, exact message, whether old device exists, whether history is readable elsewhere

**Verification:** No line containing `Этот документ должен содержать` remains.

---

### Task 5: Remove notification placeholders

**Objective:** Replace `RECOMMENDED_NOTIFICATION_MODE` and `MENTIONS_ONLY_MODE_NAME` with natural interim policy text.

**Files:**
- Modify: `knowledge/faq-notifications.md`
- Modify: `knowledge/howto-notification-settings.md`
- Mirror same files in `hermes-home/knowledge/`

**Content requirements:**
- State that no single mandatory notification profile is fixed yet.
- Recommend practical defaults: important rooms should stay enabled; noisy rooms can use mentions-only/mute where appropriate.
- Mention that labels may differ across web/desktop/mobile.

**Verification:** Raw grep finds no `RECOMMENDED_NOTIFICATION_MODE` or `MENTIONS_ONLY_MODE_NAME`.

---

### Task 6: Remove device-verification placeholders

**Objective:** Replace `DEVICE_VERIFICATION_METHOD` with safe local wording.

**Files:**
- Modify: `knowledge/howto-verify-device.md`
- Modify: `knowledge/troubleshooting-no-notifications.md`
- Mirror same files in `hermes-home/knowledge/`

**Content requirements:**
- Standard safe path: verify via already trusted old session/device, or use recovery key/Secure Backup only if the user already has it and understands it.
- If unsure: pause and write to this bot before reset.
- Do not ask users to paste keys into chat.

**Verification:** Raw grep finds no `DEVICE_VERIFICATION_METHOD`.

---

### Task 7: Fix Docker test configuration leftovers

**Objective:** Remove test-only/fake runtime values from committed Docker config while keeping Docker usable for testing.

**Files:**
- Modify: `hermes-home/config.yaml`
- Modify: `scripts/bootstrap_home.sh`
- Modify: `scripts/create_profile.sh`
- Optionally modify: `README.md`

**Content requirements:**
- Replace fake `!support-room-id:example.org` with an empty `free_response_rooms: []` list.
- Make scripts copy all canonical `knowledge/`, not just seed files.
- Make scripts derive paths from the repository instead of hardcoding `/root/element-hermes-assistant` where practical.
- Keep `hermes-home/knowledge/` as runtime mirror, not the only source.

**Verification:** No `example.org` remains in committed runtime config outside `.env.example` documentation placeholders.

---

### Task 8: Verify KB cleanliness and consistency

**Objective:** Prove the corrected KB has no raw user-facing template markers and the canonical/runtime copies match.

**Commands:**
```bash
grep -Rno --include='*.md' --include='*.yaml' --include='*.yml' -E 'ELEMENT_WEB_URL|SUPPORT_CONTACT|SECURITY_CONTACT|LOGIN_METHOD|VPN_REQUIRED|ALLOWED_CLIENTS|DEVICE_VERIFICATION_METHOD|FILE_LIMITS_DOC|ROOM_CREATION_POLICY|BYOD_POLICY|SECOND_FACTOR_METHOD|SUPPORT_HOURS|RECOMMENDED_BROWSER|RECOMMENDED_NOTIFICATION_MODE|MENTION_POLICY_DOC|SPACE_DIRECTORY_DOC|DATA_CLASSIFICATION_POLICY|GUEST_ACCESS_POLICY|HOWTO_VERIFY_DEVICE_DOC|ENCRYPTION_HELP_LINK_OR_DOC|SECURITY_ESCALATION_DOC|CALLING_POLICY_DOC|ROOM_NAMING_POLICY_DOC|SECURITY_CHANNEL|SUPPORT_CHANNEL|2FA_METHOD|MENTIONS_ONLY_MODE_NAME|WEB_URL_ИЛИ_ССЫЛКА_НА_КЛИЕНТ|SSO_ИЛИ_ЛОГИН_ПАРОЛЬ' knowledge hermes-home/knowledge

grep -RniE 'Замените|должен содержать|Рекомендуемый состав|вашу реальную|TODO|FIXME' knowledge hermes-home/knowledge

diff -qr knowledge hermes-home/knowledge
```

**Expected:** Placeholder/template scans return no problematic hits; `diff` returns no differences.

---

### Task 9: Commit and push

**Objective:** Publish the corrected KB and supporting scripts to GitHub.

**Commands:**
```bash
git status --short
git add README.md docs/plans knowledge hermes-home/knowledge hermes-home/config.yaml scripts/bootstrap_home.sh scripts/create_profile.sh
git commit -m "docs: clean and canonicalize element helpdesk knowledge base"
git push origin main
```

**Verification:** `git status -sb` shows `main...origin/main` with no local changes after push.
