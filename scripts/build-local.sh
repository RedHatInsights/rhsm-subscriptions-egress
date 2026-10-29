#!/usr/bin/env bash
# Local image build using the same Dockerfile as Konflux (needs network +
# registry.redhat.io auth for the postgresql base image).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

IMAGE_TAG="${IMAGE_TAG:-rhsm-subscriptions-egress:local}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-}"

if [ -z "${CONTAINER_ENGINE}" ]; then
  if command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE=podman
  elif command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE=docker
  else
    echo "Need podman or docker on PATH" >&2
    exit 1
  fi
fi

if [ ! -f requirements.txt ]; then
  echo "Missing requirements.txt. Run: ./scripts/refresh-requirements.sh" >&2
  exit 1
fi

echo "==> Building ${IMAGE_TAG} with ${CONTAINER_ENGINE} (Dockerfile)"
echo "    Requires registry.redhat.io login for rhel9/postgresql-13"
exec "${CONTAINER_ENGINE}" build -f Dockerfile -t "${IMAGE_TAG}" .
