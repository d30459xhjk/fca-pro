#!/bin/sh
# Redeploy the FCA PRO app to GitHub Pages (https://kingopai1.github.io/fca-pro/).
# Run after editing the source HTML. Pages auto-rebuilds in ~1 min.
set -e
SRC="/home/wes/Downloads/BerkleyFCAPROTest/FCA_PRO_App.html"
DST="/home/wes/fca-pro-site/index.html"
cp "$SRC" "$DST"
cd /home/wes/fca-pro-site
# bump the service-worker cache name so installed PWAs pull the new app when next online
perl -0pi -e "s/const CACHE = '[^']*';/const CACHE = 'fca-pro-$(date +%s)';/" sw.js
git add -A
git commit -m "update FCA PRO ($(date +%Y-%m-%d_%H:%M))" || { echo "nothing changed"; exit 0; }
git push
echo "pushed — live in ~1 min at https://kingopai1.github.io/fca-pro/"
