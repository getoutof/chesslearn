#!/usr/bin/env bash
# Run flutter commands on a remote build machine.
#
# Syncs the working tree (including uncommitted changes) over SSH and runs
# `flutter <args>` there. Build outputs stay on the remote machine.
#
#   tool/remote.sh build apk --release
#   tool/remote.sh test
#   tool/remote.sh analyze
#   tool/remote.sh --shell 'adb devices'   # arbitrary command in the project dir
#
# Connection settings: tool/remote.env (see tool/remote.env.example).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/tool/remote.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE — copy tool/remote.env.example and fill it in." >&2
  exit 1
fi
# shellcheck source=remote.env.example
. "$ENV_FILE"
: "${REMOTE_HOST:?}" "${REMOTE_USER:?}"
REMOTE_PORT="${REMOTE_PORT:-22}"
REMOTE_DIR="${REMOTE_DIR:-chesslearn}"
REMOTE_ENV="${REMOTE_ENV:-\$HOME/chessbuild.env}"

if [ $# -eq 0 ]; then
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

SSH=(ssh -o BatchMode=yes -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST")

echo "==> sync to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
rsync -az --delete \
  -e "ssh -o BatchMode=yes -p $REMOTE_PORT" \
  --exclude .git/ \
  --exclude build/ \
  --exclude .dart_tool/ \
  --exclude 'android/.gradle/' \
  --exclude 'ios/Pods/' \
  --exclude tool/remote.env \
  "$ROOT/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

if [ "$1" = "--shell" ]; then
  shift
  CMD="$*"
else
  CMD="flutter $(printf '%q ' "$@")"
fi

echo "==> $CMD"
"${SSH[@]}" ". $REMOTE_ENV && cd $REMOTE_DIR && $CMD"

# Outputs stay on the remote; just show where they are.
if [ "${1:-}" = "build" ] && { [ "${2:-}" = "apk" ] || [ "${2:-}" = "appbundle" ]; }; then
  echo "==> outputs on $REMOTE_HOST:"
  "${SSH[@]}" "cd $REMOTE_DIR && find \"\$PWD/build/app/outputs/flutter-apk\" \"\$PWD/build/app/outputs/bundle\" \
    -type f \( -name '*.apk' -o -name '*.aab' \) -exec ls -lh {} + 2>/dev/null | awk '{print \"  \" \$NF \" (\" \$5 \")\"}'"
fi
