#!/usr/bin/env bash
set -euo pipefail
REPO="${GITHUB_REPO:-hmhalvorsen/Shatterdome}"
RUNNER_NAME="${RUNNER_NAME:-shatterdome-macos-$(hostname -s | tr '[:upper:]' '[:lower:]')}"
RUNNER_DIR="${RUNNER_DIR:-$HOME/.local/share/shatterdome-actions-runner}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,macOS,ARM64,shatterdome}"
mkdir -p "$(dirname "$RUNNER_DIR")"
if [[ -d "$RUNNER_DIR" ]]; then
  echo "Runner already exists at $RUNNER_DIR — run tools/runner-teardown.sh first."
  exit 1
fi
mkdir -p "$RUNNER_DIR" && cd "$RUNNER_DIR"
RUNNER_VERSION="$(gh api repos/actions/runner/releases/latest --jq '.tag_name' | sed 's/^v//')"
ARCH="$(uname -m)"
[[ "$ARCH" == "arm64" ]] && RUNNER_ARCH="arm64" || RUNNER_ARCH="x64"
TARBALL="actions-runner-osx-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"
curl -fsSL -o "$TARBALL" "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${TARBALL}"
tar xzf "$TARBALL" && rm -f "$TARBALL"
REG_TOKEN="$(gh api --method POST "repos/${REPO}/actions/runners/registration-token" --jq '.token')"
./config.sh --url "https://github.com/${REPO}" --token "$REG_TOKEN" --name "$RUNNER_NAME" --labels "$RUNNER_LABELS" --unattended --replace
printf '#!/usr/bin/env bash\nset -euo pipefail\ncd "$(dirname "$0")"\n./run.sh\n' > "$RUNNER_DIR/start-runner.sh"
chmod +x "$RUNNER_DIR/start-runner.sh"
echo "Runner ready: $RUNNER_DIR/start-runner.sh"
