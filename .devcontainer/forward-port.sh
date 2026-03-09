#!/bin/bash
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "usage: $0 <port> [host_port]"
  echo "example: $0 5173"
  exit 1
fi

PORT="$1"
HOST_PORT="${2:-$PORT}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOST_SOCK_DIR="$REPO_ROOT/.devcontainer/socks"

CONFIG="${DEVCONTAINER_CONFIG:-.devcontainer/devcontainer.json}"
if [ -z "${DEVCONTAINER_CONFIG:-}" ] && [ -f ".devcontainer/my-override/devcontainer.json" ]; then
  CONFIG=".devcontainer/my-override/devcontainer.json"
fi

mkdir -p "$HOST_SOCK_DIR"
chmod 777 "$HOST_SOCK_DIR"

if ! command -v socat >/dev/null 2>&1; then
  echo "socat is required on the host. Install it with:"
  echo "  sudo apt-get update && sudo apt-get install -y socat"
  exit 1
fi

if ! devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "command -v socat >/dev/null 2>&1"; then
  echo "socat is required in the container. Installing..."
  devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "sudo apt-get update && sudo apt-get install -y socat"
fi

CONT_WORKSPACE="$(devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "pwd" | tail -n 1)"
CONT_SOCK_DIR="$CONT_WORKSPACE/.devcontainer/socks"
SOCK_PATH_HOST="$HOST_SOCK_DIR/p${PORT}.sock"
SOCK_PATH_CONT="$CONT_SOCK_DIR/p${PORT}.sock"
LOG_PATH_HOST="$HOST_SOCK_DIR/forward-port-${PORT}.log"
LOG_PATH_CONT="/tmp/forward-port-${PORT}.log"

if [ -z "$CONT_WORKSPACE" ]; then
  echo "Failed to detect container workspace path."
  exit 1
fi

if ! devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "mkdir -p '$CONT_SOCK_DIR'"; then
  echo "devcontainer exec failed. Is the container running?"
  exit 1
fi
PROBE_FILE=".probe.$(date +%s).$$"
devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "touch '$CONT_SOCK_DIR/$PROBE_FILE'"
if [ ! -f "$HOST_SOCK_DIR/$PROBE_FILE" ]; then
  echo "Bind mount is missing: $HOST_SOCK_DIR is not shared between host and container."
  echo "Recreate the container with:"
  echo "  devcontainer up --config $CONFIG --workspace-folder . --mount type=bind,source=$HOST_SOCK_DIR,target=$CONT_SOCK_DIR"
  exit 1
fi
rm -f "$HOST_SOCK_DIR/$PROBE_FILE" || true
devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "chmod 777 '$CONT_SOCK_DIR'"

echo "Starting container side: 127.0.0.1:${PORT} -> ${SOCK_PATH_CONT}"
devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "socat UNIX-LISTEN:'$SOCK_PATH_CONT',fork,reuseaddr TCP:127.0.0.1:${PORT} >'$LOG_PATH_CONT' 2>&1 &"

for i in $(seq 1 20); do
  if [ -S "$SOCK_PATH_HOST" ]; then
    break
  fi
  sleep 0.2
done
if [ ! -S "$SOCK_PATH_HOST" ]; then
  echo "Socket not created: $SOCK_PATH_HOST"
  if [ -f "$LOG_PATH_HOST" ]; then
    echo "Container log:"
    tail -n 50 "$LOG_PATH_HOST"
  else
    echo "Container log not found at $LOG_PATH_HOST"
  fi
  devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "tail -n 50 '$LOG_PATH_CONT' || true"
  devcontainer exec --workspace-folder=. --config "$CONFIG" bash -lc "ps -ef | grep [s]ocat || true"
  exit 1
fi

echo "Starting host side: localhost:${HOST_PORT} -> ${SOCK_PATH_HOST}"
echo "Press Ctrl-C to stop the host listener."
socat TCP-LISTEN:${HOST_PORT},fork,reuseaddr UNIX-CONNECT:${SOCK_PATH_HOST}
