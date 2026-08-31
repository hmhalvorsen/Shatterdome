#!/usr/bin/env bash
# Start the right Colima profile for release builds (free, local compute only).
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

PROFILE="${1:-arm64}"

if ! command -v colima >/dev/null; then
  echo "Error: colima is required on the self-hosted runner."
  exit 1
fi

case "$PROFILE" in
  arm64)
    CONTEXT="colima"
    PROFILE_ARGS=()
    START_ARGS=(start --cpu 4 --memory 8 --disk 60)
    ;;
  amd64)
    CONTEXT="colima-amd64"
    PROFILE_ARGS=(--profile amd64)
    START_ARGS=(start --profile amd64 --arch x86_64 --vm-type vz --vz-rosetta --cpu 4 --memory 8 --disk 60)
    ;;
  *)
    echo "Error: unknown profile '${PROFILE}' (use arm64 or amd64)"
    exit 1
    ;;
esac

if colima status ${PROFILE_ARGS+"${PROFILE_ARGS[@]}"} >/dev/null 2>&1; then
  echo "Colima profile '${PROFILE}' is running."
else
  echo "Starting Colima profile '${PROFILE}'..."
  colima "${START_ARGS[@]}"
fi

docker context use "${CONTEXT}" >/dev/null 2>&1 || docker context use default >/dev/null

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not available for context '${CONTEXT}'."
  exit 1
fi

echo "Docker ready (${PROFILE}, context ${CONTEXT})."
