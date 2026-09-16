#!/usr/bin/env bash
# Render every NEP MediaWiki document to standalone HTML and validate the JSON
# Schema files. Output is written to the git-ignored _site/ directory.
set -euo pipefail

cd "$(dirname "$0")/.."
OUT="_site"
rm -rf "$OUT"
mkdir -p "$OUT"

shopt -s nullglob

render() {
  local src="$1" name="$2"
  pandoc -f mediawiki -t html -s --metadata title="$name" -o "$OUT/$name.html" "$src"
  echo "rendered $src -> $OUT/$name.html"
}

for f in *.mediawiki; do
  render "$f" "$(basename "$f" .mediawiki)"
done

for f in obsolete/*.mediawiki; do
  render "$f" "obsolete-$(basename "$f" .mediawiki)"
done

# Simple index linking to every rendered document.
{
  echo '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
  echo '<title>NEO Enhancement Proposals</title>'
  echo '<style>body{font-family:system-ui,sans-serif;max-width:48em;margin:2em auto;padding:0 1em;color:#1a1a1a}a{color:#00a94f;text-decoration:none}a:hover{text-decoration:underline}li{margin:.25em 0}</style>'
  echo '</head><body><h1>NEO Enhancement Proposals</h1><ul>'
  for f in "$OUT"/*.html; do
    n="$(basename "$f")"
    [ "$n" = "index.html" ] && continue
    echo "<li><a href=\"$n\">${n%.html}</a></li>"
  done
  echo '</ul></body></html>'
} > "$OUT/index.html"
echo "wrote $OUT/index.html"

# Validate every JSON Schema document in the repo.
schema_count=0
while IFS= read -r -d '' schema; do
  echo "validating $schema"
  python3 -m check_jsonschema --check-metaschema "$schema"
  schema_count=$((schema_count + 1))
done < <(find . -path ./.git -prune -o -path ./_site -prune -o -name '*.schema.json' -print0)
echo "build.sh: done (validated $schema_count schema file(s))"
