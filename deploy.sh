#!/bin/sh
# Redeploy FCA-PRO to GitHub Pages. Run after editing index.html.
# Pages auto-rebuilds in ~1 min after push.
set -e
cd "$(dirname "$0")"
# bump the service-worker cache name so installed PWAs pull the new app when next online
perl -0pi -e "s/const CACHE = '[^']*';/const CACHE = 'fca-pro-$(date +%s)';/" sw.js
git add -A
git commit -m "Update app ($(date +%Y-%m-%d))" || { echo "nothing changed"; exit 0; }
git push
echo "pushed — live in ~1 min"
