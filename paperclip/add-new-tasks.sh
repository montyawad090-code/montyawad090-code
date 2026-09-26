#!/usr/bin/env bash
# Adds any TASK.md from a company package that is missing in an already-imported
# company (matched by title). Use this after pulling new tasks into a package, instead of
# re-importing, which would duplicate every existing task.
#
#   bash add-new-tasks.sh sunnah-companion-hq "Sunnah Companion HQ"
set -euo pipefail

PKG_DIR="$(cd "$(dirname "$0")" && pwd)/${1:?package folder, e.g. sunnah-companion-hq}"
COMPANY_NAME="${2:?company name, e.g. \"Sunnah Companion HQ\"}"
API="${PAPERCLIP_API:-http://127.0.0.1:3100}"

python3 - "$PKG_DIR" "$COMPANY_NAME" "$API" <<'PY' | while IFS=$'\t' read -r company title assignee project desc_file; do
import glob, json, os, sys, tempfile, urllib.request

pkg, company_name, api = sys.argv[1:4]
get = lambda p: json.load(urllib.request.urlopen(api + p))

company = next((c for c in get("/api/companies") if c["name"] == company_name), None)
if company is None:
    sys.exit(f"No company named {company_name!r} at {api}")
cid = company["id"]
agents = {a.get("urlKey") or a["name"].lower().replace(" ", "-"): a["id"] for a in get(f"/api/companies/{cid}/agents")}
agents.update({a["name"].lower().replace(" ", "-"): a["id"] for a in get(f"/api/companies/{cid}/agents")})
projects = {p.get("urlKey") or p["name"].lower().replace(" ", "-"): p["id"] for p in get(f"/api/companies/{cid}/projects")}
existing = {i["title"] for i in get(f"/api/companies/{cid}/issues?limit=1000")}

for path in sorted(glob.glob(os.path.join(pkg, "projects/*/tasks/*/TASK.md"))):
    text = open(path).read()
    _, fm, body = text.split("---", 2)
    meta = {}
    for line in fm.strip().splitlines():
        k, _, v = line.partition(":")
        meta[k.strip()] = v.strip().strip('"')
    if meta.get("recurring") == "true" or meta["name"] in existing:
        continue
    fd, desc = tempfile.mkstemp(suffix=".md")
    os.write(fd, body.strip().encode()); os.close(fd)
    print("\t".join([cid, meta["name"], agents.get(meta.get("assignee", ""), ""),
                     projects.get(meta.get("project", ""), ""), desc]))
PY
  args=(-C "$company" --title "$title" --description "$(cat "$desc_file")" --status todo --api-base "$API")
  [ -n "$assignee" ] && args+=(--assignee-agent-id "$assignee")
  [ -n "$project" ] && args+=(--project-id "$project")
  npx -y paperclipai@latest issue create "${args[@]}" >/dev/null
  rm -f "$desc_file"
  echo "Added: $title"
done
echo "Done."
