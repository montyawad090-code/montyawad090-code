#!/usr/bin/env python3
"""Bring an already-imported Paperclip company up to date with its package, safely.

Paperclip will not re-import agents into an existing company (and re-importing tasks
duplicates them), so this applies only additive changes:

  1. imports package skills the company does not have yet
  2. attaches each agent's listed skills (keeps any skills added by hand)
  3. appends the package's "## Lessons from Ayman" section to an agent's instructions
     if that section is missing (hand edits to instructions are kept)
  4. creates recurring tasks (routines) that do not exist yet, with their schedules
  5. adds one-off tasks that do not exist yet (via add-new-tasks.sh)

Usage:  python3 update-company.py sunnah-companion-hq "Sunnah Companion HQ"
"""
import glob
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
pkg_name, company_name = sys.argv[1], sys.argv[2]
PKG = os.path.join(HERE, pkg_name)
API = os.environ.get("PAPERCLIP_API", "http://127.0.0.1:3100")
LESSONS = "## Lessons from Ayman"


def get(path):
    return json.load(urllib.request.urlopen(API + path))


def cli(*args):
    result = subprocess.run(["npx", "-y", "paperclipai@latest", *args, "--api-base", API],
                            capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"paperclipai {' '.join(args[:2])} failed:\n{result.stderr or result.stdout}")
    return result.stdout


def front_matter(path):
    _, fm, body = open(path).read().split("---", 2)
    meta, key = {}, None
    for line in fm.strip().splitlines():
        if line.startswith("  - ") and key:
            meta.setdefault(key, []).append(line[4:].strip())
            continue
        key, _, value = line.partition(":")
        key = key.strip()
        if value.strip():
            meta[key] = value.strip().strip('"')
    return meta, body.strip()


def say(msg):
    print(f"  {msg}", flush=True)


company = next((c for c in get("/api/companies") if c["name"] == company_name), None)
if company is None:
    sys.exit(f"No company named {company_name!r} at {API}")
cid = company["id"]
print(f"Updating {company_name}")

# 1. Skills
have = json.loads(cli("skills", "list", "-C", cid, "--json"))
have_keys = {s.get(k) for s in have for k in ("slug", "key", "name") if s.get(k)}
for skill_dir in sorted(glob.glob(os.path.join(PKG, "skills", "*"))):
    slug = os.path.basename(skill_dir)
    if slug not in have_keys:
        # Paperclip only imports skills from approved workspace folders, so create it instead.
        meta, body = front_matter(os.path.join(skill_dir, "SKILL.md"))
        fd, tmp = tempfile.mkstemp(suffix=".md")
        os.write(fd, (body + "\n").encode())
        os.close(fd)
        cli("skills", "create", "--name", meta["name"], "--slug", slug,
            "--description", meta.get("description", ""), "--body-file", tmp, "-C", cid)
        os.unlink(tmp)
        say(f"added skill {slug}")

# 2 + 3. Agents
agents = {a.get("urlKey"): a["id"] for a in get(f"/api/companies/{cid}/agents")}
for agent_md in sorted(glob.glob(os.path.join(PKG, "agents", "*", "AGENTS.md"))):
    meta, body = front_matter(agent_md)
    agent_id = agents.get(meta.get("slug"))
    if not agent_id:
        say(f"agent {meta.get('slug')} not found; skipped")
        continue
    if meta.get("skills"):
        cli("agent", "skills:sync", agent_id, "--desired-skills", ",".join(meta["skills"]), "--mode", "add")
        say(f"{meta['name']}: skills {', '.join(meta['skills'])}")
    if LESSONS in body:
        current = json.loads(cli("agent", "instructions-file:get", agent_id, "--path", "AGENTS.md", "--json"))
        text = current.get("content") or ""
        if LESSONS not in text:
            lessons = body[body.index(LESSONS):]
            fd, tmp = tempfile.mkstemp(suffix=".md")
            os.write(fd, (text.rstrip() + "\n\n" + lessons + "\n").encode())
            os.close(fd)
            cli("agent", "instructions-file:put", agent_id, "--path", "AGENTS.md", "--content-file", tmp)
            os.unlink(tmp)
            say(f"{meta['name']}: added lessons to instructions")

# 4. Routines
ext = open(os.path.join(PKG, ".paperclip.yaml")).read()
existing_routines = {r["title"] for r in get(f"/api/companies/{cid}/routines")}
projects = {p.get("urlKey"): p["id"] for p in get(f"/api/companies/{cid}/projects")}
for task_md in sorted(glob.glob(os.path.join(PKG, "projects", "*", "tasks", "*", "TASK.md"))):
    meta, body = front_matter(task_md)
    if meta.get("recurring") != "true" or meta["name"] in existing_routines:
        continue
    block = re.search(rf"\n  {re.escape(meta['slug'])}:\n(?:    .*\n|      .*\n)*", ext)
    cron = re.search(r'cronExpression: "([^"]+)"', block.group(0)) if block else None
    tz = re.search(r"timezone: (\S+)", block.group(0)) if block else None
    payload = {"title": meta["name"], "description": body,
               "assigneeAgentId": agents.get(meta.get("assignee")),
               "projectId": projects.get(meta.get("project"))}
    routine = json.loads(cli("routine", "create", "-C", cid, "--payload-json", json.dumps(payload), "--json"))
    if cron:
        trigger = {"kind": "schedule", "cronExpression": cron.group(1),
                   "timezone": tz.group(1) if tz else "Europe/London"}
        cli("routine", "trigger:create", routine["id"], "--payload-json", json.dumps(trigger))
    say(f"created routine {meta['name']}" + (f" ({cron.group(1)})" if cron else ""))

# 5. One-off tasks
subprocess.run(["bash", os.path.join(HERE, "add-new-tasks.sh"), pkg_name, company_name],
               check=True, env={**os.environ, "PAPERCLIP_API": API})
