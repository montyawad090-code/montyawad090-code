---
name: Audit reminder dispatch failure modes
slug: reminder-failure-audit
assignee: engineer
project: sunnah-companion
---

List every way a reminder could fail to send, send late, or send twice: host restart,
clock or timezone and DST changes, prayer-time API outage, Telegram rate limits, duplicate
processes. For each, state whether current code handles it and how you know (test or code
reference). Propose fixes only for the unhandled ones, as separate small PRs.
