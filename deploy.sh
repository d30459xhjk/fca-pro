#!/bin/sh
set -e
cd "$(dirname "$0")"
perl -0pi -e "s/const CACHE = '[^']*';/const CACHE = 'fca-pro-$(date +%s)';/" sw.js
git add -A
git commit -m "Update app ($(date +%Y-%m-%d))" || { echo "nothing changed"; exit 0; }
git push
echo "pushed — live in ~1 min"
