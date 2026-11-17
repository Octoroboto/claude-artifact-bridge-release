#!/bin/zsh
# claude-artifact-bridge 1.0.0 - watch.sh
#
# What it's for: if you don't already have a job runner, leave this running in a Terminal window. Every few seconds it
# looks in requests/ for a request that has no result yet and runs it through bridge.sh, one at a time (oldest first).
# A Claude chat with a shell on this computer then only has to drop a file into requests/ and read results/.
#
# Usage: zsh watch.sh        (Ctrl-C to stop)   Optional: BRIDGE_POLL=<seconds> (default 5)
# One copy at a time: a lock folder stops a second watcher from running the same request twice.
set -u
B="${0:A:h}"; LOCK="$B/.watch.lock"
mkdir "$LOCK" 2>/dev/null || { echo "watch.sh is already running (remove $LOCK if it isn't)"; exit 1; }
trap 'rmdir "$LOCK" 2>/dev/null; exit' INT TERM EXIT
echo "Watching $B/requests (Ctrl-C to stop)"
while true; do
  # (N) = no error when the folder is empty; (Om) = oldest first
  for f in "$B"/requests/*.md(NOm); do
    n="${f:t:r}"                                   # file name without folder and .md
    [ -e "$B/results/$n.txt" ] && continue          # already done
    echo "$(date +%T) running $n"
    zsh "$B/bridge.sh" "$n" | tail -1
  done
  sleep "${BRIDGE_POLL:-5}"
done
