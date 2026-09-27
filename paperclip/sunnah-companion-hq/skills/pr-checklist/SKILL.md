---
name: pr-checklist
description: The checklist every Sunnah Companion pull request must pass before it is sent to Ayman for approval.
slug: pr-checklist
tags:
  - engineering
  - review
---

# PR Checklist

Engineer runs this before opening a PR; Lead runs it again before asking Ayman to approve.

- [ ] Work happened in a repository attached to the Sunnah Companion project. If none is
      attached, stop and ask Lead instead of writing code elsewhere.
- [ ] One purpose per PR; under ~200 changed lines unless Lead agreed otherwise.
- [ ] No new dependencies (or a written justification Ayman approved).
- [ ] Bot changes: tests added or updated and passing; dispatch stays idempotent
      (a reminder fires once or not at all).
- [ ] PWA changes: real-phone test plan for Android Chrome and iOS Safari, including offline
      launch and install-to-home-screen.
- [ ] No secrets, tokens or user data in the diff or logs.
- [ ] Adhkar text, hadith references and prayer calculation settings unchanged, or changed
      with a cited source and flagged for Ayman.
- [ ] PR description: what changed, why, how it was tested, and what it cannot do.
