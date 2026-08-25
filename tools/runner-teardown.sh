#!/usr/bin/env bash
set -euo pipefail
REPO="${GITHUB_REPO:-hmhalvorsen/Shatterdome}"
RUNNER_DIR="${RUNNER_DIR:-$HOME/.local/share/shatterdome-actions-runner}"
[[ -d "$RUNNER_DIR" ]] || { echo "No runner at $RUNNER_DIR"; exit 0; }
cd "$RUNNER_DIR"
pgrep -f "$RUNNER_DIR/run.sh" >/dev/null 2>&1 && pkill -f "$RUNNER_DIR/run.sh" || true
sleep 2
if [[ -f ./config.sh ]]; then
  REMOVE_TOKEN="$(gh api --method POST "repos/${REPO}/actions/runners/remove-token" --jq '.token' 2>/dev/null || true)"
  [[ -n "${REMOVE_TOKEN:-}" ]] && ./config.sh remove --token "$REMOVE_TOKEN" || true
fi
cd / && rm -rf "$RUNNER_DIR"
echo "Runner removed."
