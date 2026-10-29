#!/usr/bin/env bash
# Regenerate requirements.txt from requirements.in (Hermeto pip lockfile).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v uv >/dev/null 2>&1; then
  uv pip compile --generate-hashes --python-version 3.9 -o requirements.txt requirements.in
elif command -v pip-compile >/dev/null 2>&1; then
  pip-compile --generate-hashes --output-file=requirements.txt requirements.in
else
  echo "Need uv or pip-compile (pip-tools) on PATH" >&2
  exit 1
fi

echo "Updated requirements.txt. Optionally sync Pipfile.lock: pipenv lock"
