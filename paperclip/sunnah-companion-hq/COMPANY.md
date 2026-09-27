---
schema: agentcompanies/v1
name: Sunnah Companion HQ
slug: sunnah-companion-hq
description: A small agent team that keeps Sunnah Companion reliable and improving while its one human is busy studying and flying.
version: 0.1.0
authors:
  - name: Ayman Ahmed
goals:
  - Keep sunnah-bot delivering every reminder exactly once, on time, with no silent failures.
  - Keep the Sunnah Companion PWA fast, offline-capable and bug-free on real phones.
  - Turn ideas into small, reviewable, shipped improvements without eating study time.
---

Sunnah Companion HQ runs the maintenance and improvement work for:

- **sunnah-bot**: Python Telegram bot for prayer-time, adhkar and daily reminders.
  One third-party dependency, idempotent dispatch, running unattended.
- **Sunnah Companion**: installable PWA (vanilla HTML/CSS/JS, no build step,
  offline-capable) at sunnahcompanion.com.

## House rules for every agent

1. The human (Ayman) is a full-time Aerospace Engineering student with flight training.
   Their time is the scarcest resource. Batch questions, keep updates short, never ask
   for something you can find in the repo.
2. Few dependencies. Adding one needs a written justification and human approval.
3. Reliability beats features. A reminder fires once or not at all, never twice.
4. Everything ships as a small PR with a test or a written manual test plan.
   Nothing merges without human approval.
5. Write down what something *cannot* do rather than dressing limits up as features.
6. Never commit secrets, tokens, or user data. Stop and escalate if you see any.
7. Religious content (adhkar text, hadith references, prayer calculation methods) is never
   invented or reworded. Changes to it need a cited source and human approval.
