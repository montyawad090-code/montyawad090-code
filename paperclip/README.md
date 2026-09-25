# Paperclip setup: Sunnah Companion HQ

A ready-to-import [Paperclip](https://github.com/paperclipai/paperclip) company that runs
maintenance and improvement work on sunnah-bot and the Sunnah Companion PWA, so less of it
lands on me during term.

## What's inside

```text
sunnah-companion-hq/
├── COMPANY.md                 goals + house rules every agent follows
├── .paperclip.yaml            adapters, monthly budgets, routine schedules
├── agents/
│   ├── lead/AGENTS.md         plans, assigns, reviews, protects my time
│   ├── engineer/AGENTS.md     small PRs to the bot and the PWA
│   └── ops/AGENTS.md          read-only daily reliability check
└── projects/sunnah-companion/
    ├── PROJECT.md
    └── tasks/                 3 starter tasks + 4 recurring routines
```

**Org chart:** Me (approves everything) → Lead → Engineer, Ops.

**Routines** (Europe/London):

| Routine | Agent | When |
| --- | --- | --- |
| Daily health check | Ops | Every day 07:12 |
| Weekly triage | Lead | Monday 07:47 |
| Dependency and security check | Engineer | Wednesday 18:20 |
| Changelog draft | Lead | Friday 16:40 |

**Budgets** (monthly caps, in the currency Paperclip bills in): Lead 15, Engineer 20, Ops 5.
Raise them only once a month of runs shows what the real spend is.

## How to use it

Needs Node.js 24.11+ and an Anthropic API key, on my own laptop or a small always-on server.

```bash
# 1. Try Paperclip in a throwaway sandbox first
ANTHROPIC_API_KEY=... npx paperclipai test-drive

# 2. Install for real
npx --registry https://registry.npmjs.org paperclipai onboard --yes

# 3. Preview, then import this company
npx paperclipai company import ./paperclip/sunnah-companion-hq --target new \
  --new-company-name "Sunnah Companion HQ" --dryRun
npx paperclipai company import ./paperclip/sunnah-companion-hq --target new \
  --new-company-name "Sunnah Companion HQ"
```

Then in the Paperclip UI:

1. Add `ANTHROPIC_API_KEY` (and `GH_TOKEN` for PRs) as company secrets.
2. Attach the sunnah-bot and PWA repos to the **Sunnah Companion** project.
3. Approve Lead's plan for the **Onboard both repos** task. Everything else follows from it.

## Adding ideas

Any idea becomes a task in the Sunnah Companion project, assigned to Lead. Lead scopes it,
hands it to Engineer, and it comes back to me as a PR to approve.

## What this cannot do

- It does not manage uni, flight training or personal tasks. Those live in Notion.
- Agents never merge, deploy or restart production. I do.
- It only runs while the Paperclip server is running. A laptop that is asleep runs no routines.
