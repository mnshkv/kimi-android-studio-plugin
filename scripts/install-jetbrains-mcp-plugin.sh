#!/bin/bash
# Install JetBrains' official "MCP Server" plugin into Android Studio.
# Picks the newest Android Studio config under ~/Library/Application Support/Google.
# Idempotent: skips if already installed.
set -euo pipefail

BUILD="$(cd /tmp && python3 - <<'EOF'
import json, os, glob
candidates = sorted(glob.glob(os.path.expanduser("~/Applications/Android Studio.app/Contents/Resources/product-info.json")))
if candidates:
    d = json.load(open(candidates[-1]))
    print(d.get("buildNumber", ""))
EOF
)"

if [ -z "${BUILD}" ]; then
    echo "error: Android Studio not found in ~/Applications" >&2
    exit 1
fi

CONFIG_DIR="$(ls -d ~/Library/Application\ Support/Google/AndroidStudio* 2>/dev/null | sort -V | tail -1 || true)"
if [ -z "${CONFIG_DIR}" ]; then
    echo "error: Android Studio config directory not found" >&2
    exit 1
fi
CONFIG_DIR="${CONFIG_DIR//\\ / }"

DEST="${CONFIG_DIR}/plugins/McpServer"
if [ -d "${DEST}" ]; then
    echo "already installed at ${DEST}"
    exit 0
fi

echo "Resolving MCP Server plugin compatible with build ${BUILD}..."
UPDATE_ID="$(python3 - "$BUILD" <<'EOF'
import json, sys, urllib.request
build = sys.argv[1]
url = "https://plugins.jetbrains.com/api/search/plugins?search=MCP&build=%s&max=10" % build
with urllib.request.urlopen(url, timeout=30) as r:
    data = json.load(r)
plugins = data if isinstance(data, list) else data.get("plugins", [])
for p in plugins:
    if p.get("xmlId") == "com.intellij.mcpServer" and p.get("updateId"):
        print(p["updateId"])
        break
EOF
)"

if [ -z "${UPDATE_ID}" ]; then
    echo "error: no MCP Server plugin update found for build ${BUILD}" >&2
    exit 1
fi

URL="https://plugins.jetbrains.com/plugin/download?updateId=${UPDATE_ID}"
TMP="$(mktemp -d)"
curl -fSL --retry 3 -o "${TMP}/mcp.zip" "${URL}"

echo "Installing into ${DEST}..."
mkdir -p "${DEST}"
unzip -q "${TMP}/mcp.zip" -d "${DEST}"
rm -rf "${TMP}"

# Some archives wrap the plugin in a single nested directory; flatten it.
if [ ! -d "${DEST}/lib" ]; then
    NESTED="$(find "${DEST}" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [ -n "${NESTED}" ] && [ -d "${NESTED}/lib" ]; then
        (cd "${NESTED}" && mv * ../)
        rm -rf "${NESTED}"
    fi
fi

cat <<EOF
Installed. Now:
1. Restart Android Studio.
2. Settings -> Tools -> MCP Server -> enable the server (port 63342).
3. Add http://127.0.0.1:63342 as an MCP server in Kimi Code (config.toml / 'kimi mcp add').
EOF
