#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dev entrypoint (single-container) for openIMIS CSU frontend
# -----------------------------------------------------------------------------
# Goal:
# - Use openimis.json or openimis-dev.json as source of truth
# - Keep default dependencies from openimis.json (git/version) for non-local modules
# - Auto-detect locally cloned modules mounted under /workspace and override them
#   via yarn symlinks (yarn link) for true live development
# - Start Rollup watchers only for local linked modules
# - Start frontend dev server
# -----------------------------------------------------------------------------

APP_DIR="/workspace/openimis-fe_js"
CONFIG_FILE="${OPENIMIS_CONFIG_FILE:-openimis.json}"
PORT="${PORT:-3001}"

cd "$APP_DIR"

echo "[fix] ensuring correct permissions on workspace"
mkdir -p "$APP_DIR/node_modules"p
chown -R node:node "$APP_DIR" 2>/dev/null || true

compute_hash() {
  # Print a deterministic hash from existing files passed as args.
  # Missing files are ignored to keep the function reusable.
  local files=()
  for f in "$@"; do
    [ -f "$f" ] && files+=("$f")
  done

  if [ "${#files[@]}" -eq 0 ]; then
    echo "no-files"
    return 0
  fi

  sha256sum "${files[@]}" | sha256sum | awk '{print $1}'
}

ensure_install_if_needed() {
  # Usage: ensure_install_if_needed <dir> <hash-file> <dep-file...>
  local dir="$1"
  local hash_file="$2"
  shift 2
  local dep_files=("$@")

  local old_hash=""
  local new_hash=""
  [ -f "$hash_file" ] && old_hash="$(cat "$hash_file" 2>/dev/null || true)"
  new_hash="$(compute_hash "${dep_files[@]}")"

  if [ ! -d "$dir/node_modules" ]; then
    echo "[deps] $dir -> node_modules missing, yarn install"
    (cd "$dir" && yarn install)
    echo "$new_hash" > "$hash_file"
    return 0
  fi

  if [ "$old_hash" != "$new_hash" ]; then
    echo "[deps] $dir -> dependency fingerprint changed, yarn install"
    (cd "$dir" && yarn install)
    echo "$new_hash" > "$hash_file"
    return 0
  fi

  echo "[deps] $dir -> dependencies unchanged, skip install"
}

echo "[step 1/5] Generate frontend config from ${CONFIG_FILE}"
# This regenerates package.json openIMIS deps + src/modules.js + src/locales.js
node openimis-config.js "$CONFIG_FILE"

echo "[step 2/5] Install frontend dependencies (if needed)"
ensure_install_if_needed \
  "$APP_DIR" \
  "$APP_DIR/node_modules/.deps.hash" \
  "$APP_DIR/package.json" \
  "$APP_DIR/yarn.lock" \
  "$APP_DIR/$CONFIG_FILE"

echo "[step 3/5] Detect local modules and create symlink overrides"
# Build a list of modules that exist locally and can override defaults.
# Output format: <packageName>\t<workspaceDir>
node <<'NODE' > /tmp/csu-local-link-targets.tsv
const fs = require('fs');
const path = require('path');

const appDir = '/workspace/openimis-fe_js';
const cfgPath = path.join(appDir, process.env.OPENIMIS_CONFIG_FILE || 'openimis.json');
const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));

function parsePkg(npmRef) {
  const at = npmRef.lastIndexOf('@');
  if (at <= 0) return null;
  return npmRef.slice(0, at);
}

function pkgToLocalDir(pkgName) {
  const raw = pkgName.split('/')[1];
  if (!raw) return null;
  // repo naming exceptions used in CSU workspace
  if (raw === 'fe-cache') return '/workspace/openimis-fe-cache-manager_js';
  if (raw === 'fe-language_fr_cmr_csu') return '/workspace/openimis-fe-language_fr_cmr_csu_js-';
  return `/workspace/openimis-${raw}_js`;
}

const seen = new Set();
for (const m of cfg.modules || []) {
  const pkg = parsePkg(m.npm || '');
  if (!pkg || seen.has(pkg)) continue;
  seen.add(pkg);

  const localDir = pkgToLocalDir(pkg);
  if (!localDir) continue;

  const hasLocal = fs.existsSync(localDir) && fs.existsSync(path.join(localDir, 'package.json'));
  if (hasLocal) {
    process.stdout.write(`${pkg}\t${localDir}\n`);
  }
}
NODE

# Register each local module as a global yarn link and link it into frontend app.
# This creates symlinks inside /workspace/openimis-fe_js/node_modules/@openimis/*.
if [ -s /tmp/csu-local-link-targets.tsv ]; then
  while IFS=$'\t' read -r pkg local_dir; do
    [ -n "$pkg" ] || continue
    [ -n "$local_dir" ] || continue

    echo "[link] register $pkg from $local_dir"
    (
      cd "$local_dir"
      yarn link
    )

    echo "[link] attach $pkg to frontend"
    yarn link "$pkg"
  done < /tmp/csu-local-link-targets.tsv
else
  echo "[link] no local modules detected under /workspace"
fi

echo "[step 4/5] Start Rollup watch on local linked modules"
# Watchers are started only for modules actually linked in step 3.
# You can override this behavior by setting WATCH_MODULES with a comma-separated
# list of workspace folder names, e.g. WATCH_MODULES=openimis-fe-core_js,openimis-fe-location_js
WATCH_MODULES_AUTO="$(awk -F $'\t' '{print $2}' /tmp/csu-local-link-targets.tsv 2>/dev/null | xargs -n1 basename | paste -sd, - || true)"
WATCH_MODULES="${WATCH_MODULES:-$WATCH_MODULES_AUTO}"

if [ -n "$WATCH_MODULES" ]; then
  IFS=',' read -ra MODULES <<< "$WATCH_MODULES"
  for module in "${MODULES[@]}"; do
    module="$(echo "$module" | xargs)"
    [ -n "$module" ] || continue

    module_dir="/workspace/$module"
    if [ ! -d "$module_dir" ] || [ ! -f "$module_dir/package.json" ]; then
      echo "[watch] skip $module (not mounted or missing package.json)"
      continue
    fi

    (
      cd "$module_dir"
      ensure_install_if_needed \
        "$module_dir" \
        "$module_dir/node_modules/.deps.hash" \
        "$module_dir/package.json" \
        "$module_dir/yarn.lock"
      echo "[watch] $module -> yarn start (rollup -w)"
      exec yarn start
    ) &
  done
else
  echo "[watch] no module watcher started"
fi

echo "[step 5/5] Start frontend dev server on port ${PORT}"
exec bash -lc "PORT=${PORT} yarn start"
