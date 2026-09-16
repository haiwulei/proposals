#!/usr/bin/env bash
# Idempotent setup for the NEO Enhancement Proposals (NEPs) docs repo.
# Installs the tooling used to preview NEP MediaWiki documents and validate
# the JSON Schema files shipped with the proposals.
set -euo pipefail

# System package: pandoc renders the .mediawiki documents to HTML for preview.
if ! command -v pandoc >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends pandoc
fi

# Python tooling: check-jsonschema validates the *.schema.json files.
# Ubuntu 24.04 ships an externally-managed Python, hence --break-system-packages.
python3 -m pip install --user --break-system-packages --upgrade check-jsonschema

echo "install.sh: done ($(pandoc --version | head -1); $(python3 -m check_jsonschema --version))"
