#!/usr/bin/env bash
# Start Colima/Docker on the self-hosted runner when needed (no GitHub-hosted cost).
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if docker info >/dev/null 2>&1; then
  echo "Docker is running."
  exit 0
fi

if command -v colima >/dev/null; then
  echo "Starting Colima..."
  colima start --cpu 4 --memory 8 --disk 60
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not available. Install Colima or Docker Desktop on the runner."
  exit 1
fi

echo "Docker is ready."
