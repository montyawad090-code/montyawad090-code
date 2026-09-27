---
name: placement-check
description: Verify an opportunity, screen it for eligibility, de-duplicate it and record it in Ayman's Notion Tasks database.
slug: placement-check
tags:
  - careers
  - notion
---

# Placement Check

Use this skill for every opportunity found in a scan, before recommending it.

## 1. Verify
Open the official employer page. Record: employer, role, type (summer / year-long / part-time),
location, closing date (or "rolling"), link. If you cannot find an official page, drop it.

## 2. Screen
- **Security clearance / nationality:** if the role needs UK security clearance (SC, DV, BPSS
  plus residency) or UK nationality, mark it "Clearance required" and do not recommend it
  unless Ayman has said otherwise. Leonardo SC normally needs 5 years UK residency.
- **Visa / right to work:** never judge eligibility. If the role mentions sponsorship or
  right to work, add "Check with UWE Immigration Advice".
- **Level:** must accept current undergraduates (penultimate year for year-long placements).

## 3. De-duplicate
Search the Notion Tasks database (below) for the employer name. If a task for the same employer
and programme exists, do not create another; add a comment on the Paperclip task instead.

## 4. Record (only if the Notion connector is available)
Create a page in Ayman's Notion **Tasks** database:
- Database: https://app.notion.com/p/e811102ccaec4024bd266490c89f0303
  (data source `collection://94527a9a-5ae5-4573-8979-a7a8ad98a1eb`)
- Properties: **Task** = "Apply: <Employer> <programme>" (or "Watch: ..." if not open yet),
  **Area** = `Work & Placements`, **Status** = `To do`, **Type** = `Task` (or `Waiting on` if not open),
  **Priority** = `This week` if it closes within 14 days, else `Later`,
  **Source** = `agent`, **Link** = official URL, **Due** = closing date if known,
  **Notes** = "Added by Career Scout <date>. <one-line why + any flags>".
- Never edit or delete rows you did not create. Never set Status to Done.

If Notion is not connected, put the same fields in a table in your task comment instead.
