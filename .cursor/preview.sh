#!/usr/bin/env bash
# Build the NEP preview site and serve it for local browsing.
set -euo pipefail

cd "$(dirname "$0")/.."
bash .cursor/build.sh
cd _site
echo "Serving NEP preview on http://0.0.0.0:8000"
exec python3 -m http.server 8000 --bind 0.0.0.0
