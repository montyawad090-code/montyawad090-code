# Paperclip setup: Sunnah Companion HQ + Career & Study HQ

A ready-to-import [Paperclip](https://github.com/paperclipai/paperclip) company that runs
maintenance and improvement work on sunnah-bot and the Sunnah Companion PWA, so less of it
lands on me during term.

## Career & Study HQ

A second company for placements, UWE studies and PPL flight training.

**Org chart:** Me → Chief of Staff → Career Scout, Study Coach, Flight Coach.

**Starter tasks:**
- Airbus Wave 1 brief (closes 27 Sep)
- Francis Crick placement brief (5 Oct)
- Careers-fair prep (14 Oct)
- Master CV
- Module map
- NMC expression-of-interest checklist (17 Oct)
- PPL roadmap

**Routines** (Europe/London):
- Monday 08:17: opportunity scan
- Saturday 10:24: ground-school quiz
- Sunday 09:33: practice set
- Sunday 17:52: weekly plan

**House rules:** agents never send, submit or book anything, and never write assessed work
(UWE academic integrity). Facts need official sources.

## Improving the agents

- **Skills** (reusable methods the agents follow):
  - `application-brief`: one-page brief format per role.
  - `placement-check`: verify, screen for clearance and visa flags, de-duplicate, then add to Notion Tasks with Source = `agent`.
  - `teach-it`: example-first explanations.
  - `pr-checklist`: the gate every Sunnah PR must pass.
- **Lessons:** each `AGENTS.md` ends with `## Lessons from Ayman`. When an agent repeats a
  mistake, add a line there (or edit the agent's instructions in the Paperclip UI).
- **Monthly agent review** (Chief of Staff, 1st of the month): what each agent delivered, what to
  cut, one instruction change per agent. Ayman decides.
- **Connectors to add in Paperclip:**
  - GitHub, so Engineer can open real PRs.
  - Notion, so Career Scout can write to Tasks (without it, the agent puts a table in its comment).
  - Gmail (optional, read-only).
- **Context:** attach your CV to *Build a master CV*, and the module topic lists to *Set up the module map*.

## Updating an existing install

Paperclip will not re-import agents into an existing company, and re-importing tasks
duplicates them. Re-run the installer, or run:

```bash
python3 paperclip/update-company.py career-study-hq "Career & Study HQ"
python3 paperclip/update-company.py sunnah-companion-hq "Sunnah Companion HQ"
```

It only ever **adds**:
- missing skills, which it then attaches to the right agents;
- a missing lessons section, appended to an agent's instructions (hand edits are kept);
- missing routines;
- missing one-off tasks.

## What's inside (Sunnah Companion HQ)

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

## Quick install (Windows)

1. PowerShell **as Administrator**:
   ```powershell
   irm https://raw.githubusercontent.com/montyawad090-code/montyawad090-code/main/paperclip/install-windows.ps1 | iex
   ```
   Installs WSL2 + Ubuntu and turns on mirrored networking. Restart if it asks.
2. Open **Ubuntu** from the Start menu and paste:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/montyawad090-code/montyawad090-code/main/paperclip/install-wsl.sh | bash
   ```
   Installs Node 24 and the Claude Code CLI, starts Paperclip and imports this company.
   Both scripts are safe to re-run.
3. Open **http://localhost:3100** in your Windows browser.

The manual steps below do the same thing by hand.

## How to use it

Needs **Node.js 24.11+**, an Anthropic API key, and the `claude` CLI (the agents run on
Claude Code). Paperclip supports macOS, Linux and **WSL2**. On my Windows PC that means
running everything inside WSL2 (`wsl --install` in an admin PowerShell), not in PowerShell.

Always use `paperclipai@latest`: a cached older `npx paperclipai` may be missing commands
such as `test-drive`.

```bash
# 1. Try Paperclip in a throwaway sandbox first
ANTHROPIC_API_KEY=... npx paperclipai@latest test-drive

# 2. Install for real
npx --registry https://registry.npmjs.org paperclipai@latest onboard --yes

# 3. Preview, then import this company
npx paperclipai@latest company import ./paperclip/sunnah-companion-hq --target new \
  --new-company-name "Sunnah Companion HQ" --dry-run
npx paperclipai@latest company import ./paperclip/sunnah-companion-hq --target new \
  --new-company-name "Sunnah Companion HQ"
```

Tested against Paperclip 2026.916.1: the import creates 3 agents (Engineer and Ops report to
Lead, budgets applied), 1 project, 3 starter tasks and 4 active routines on Europe/London
schedules. The only warning is a harmless note about the package schema version.

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
