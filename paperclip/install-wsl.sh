#!/usr/bin/env bash
# One-shot Paperclip setup for Sunnah Companion HQ, run inside Ubuntu (WSL2).
#
#   curl -fsSL https://raw.githubusercontent.com/montyawad090-code/montyawad090-code/main/paperclip/install-wsl.sh | bash
#
# Safe to run again: it skips anything already done.
set -euo pipefail

REPO_URL="https://github.com/montyawad090-code/montyawad090-code.git"
REPO_DIR="$HOME/montyawad090-code"
BRANCH="${PAPERCLIP_SETUP_BRANCH:-main}"
COMPANY_NAME="Sunnah Companion HQ"
PORT=3100
BIND="${PAPERCLIP_BIND:-loopback}"
export NVM_DIR="$HOME/.nvm"

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# 1. Node.js 24+ via nvm
# nvm is not compatible with `set -u`, so relax it while nvm runs.
load_nvm() {
  set +u
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  "$@"
  set -u
}
if [ -s "$NVM_DIR/nvm.sh" ]; then load_nvm nvm use --silent 24 >/dev/null 2>&1 || true; fi
node_major() { node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0; }
if [ "$(node_major)" -lt 24 ]; then
  say "Installing Node.js 24 (via nvm)"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
  load_nvm nvm install 24
  load_nvm nvm alias default 24
fi
say "Node $(node --version)"

# 2. Claude Code CLI (the agents run on it)
if ! command -v claude >/dev/null 2>&1; then
  say "Installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code
fi

# 3. This repo (holds the company package)
if [ ! -d "$REPO_DIR/.git" ]; then
  say "Cloning $REPO_URL"
  git clone "$REPO_URL" "$REPO_DIR"
fi
git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"
git -C "$REPO_DIR" checkout --quiet "$BRANCH"
git -C "$REPO_DIR" pull --quiet --ff-only origin "$BRANCH" || true
PACKAGE="$REPO_DIR/paperclip/sunnah-companion-hq"

# 4. Start Paperclip (first run also onboards)
health() { curl -fsS "http://127.0.0.1:$PORT/api/health" >/dev/null 2>&1; }
LOG="$HOME/.paperclip-server.log"
if health; then
  say "Paperclip is already running"
  SERVER_PID=""
else
  say "Starting Paperclip (log: $LOG)"
  if [ -f "$HOME/.paperclip/instances/default/config.json" ]; then
    npx -y paperclipai@latest run >"$LOG" 2>&1 &
  else
    npx -y paperclipai@latest onboard --yes --bind "$BIND" --no-install-service >"$LOG" 2>&1 &
  fi
  SERVER_PID=$!
  for _ in $(seq 1 150); do
    health && break
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
      echo "Paperclip stopped during startup. Last lines of $LOG:"; tail -20 "$LOG"; exit 1
    fi
    sleep 2
  done
  health || { echo "Paperclip did not come up in time. See $LOG"; exit 1; }
fi

# 5. Import the company once
if curl -fsS "http://127.0.0.1:$PORT/api/companies" | grep -q "\"$COMPANY_NAME\""; then
  say "$COMPANY_NAME already imported"
else
  say "Importing $COMPANY_NAME"
  npx -y paperclipai@latest company import "$PACKAGE" --target new \
    --new-company-name "$COMPANY_NAME" --yes --api-base "http://127.0.0.1:$PORT"
fi

cat <<EOF

  Done. Open http://localhost:$PORT in your Windows browser.

  Next, in the Paperclip UI:
    1. Company settings -> Secrets: add ANTHROPIC_API_KEY (and GH_TOKEN for PRs)
    2. Projects -> Sunnah Companion: attach the sunnah-bot and PWA repos

  To start Paperclip again later:  npx paperclipai@latest run
EOF

if [ -n "${SERVER_PID:-}" ]; then
  echo "  Keep this window open while you use Paperclip. Ctrl+C stops it."
  wait "$SERVER_PID"
fi
