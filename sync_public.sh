#!/bin/bash
# sync_public.sh — force-sync public ← dev (SpidertronHunter pattern)

set -euo pipefail

git checkout dev

read -r -p "Enter tag name (leave blank to skip): " TAG
if [ -n "${TAG}" ]; then
  git tag -a "${TAG}" -m "Release ${TAG}"
  git push --tags
fi

git switch public
git reset --hard dev
git push --force
git switch dev
echo "Public branch synced with dev successfully!"
