#!/bin/zsh
# claude-artifact-bridge 1.0.0 - bridge.sh
#
# What it's for: lets a Claude chat that is NOT allowed to change an existing claude.ai artifact (for example a cloud
# Cowork / project chat that gets "network_off: ... this session did not make this artifact") get that change made
# anyway, by handing it to Claude Code running on YOUR OWN computer, signed in to the same claude.ai account.
#
# Why that works: artifacts belong to your claude.ai ACCOUNT, not to the chat that made them. A local Claude Code run is
# not a cloud chat, so it can update any artifact your account owns or can edit, as chats used to.
#
# How it's used:
#   1. Something (a Claude chat with a shell on this computer, a script, or you) writes a request file:
#        requests/<name>.md   - plain-language instructions: the artifact's URL and exactly what to change.
#   2. Run:  zsh bridge.sh <name>      (or let watch.sh run every new request for you)
#   3. Read: results/<name>.txt        - Claude's answer; its last line is "BRIDGE_RESULT: OK ..." or "BRIDGE_RESULT: FAIL ..."
#            results/<name>.json       - the full JSON output of the run (cost, turns, session id)
#
# What it runs: `claude -p` (Claude Code, headless) with
#   - CLAUDE_CODE_ARTIFACT=1, which turns the artifact tools on in -p runs (they're off there by default);
#   - --permission-mode bypassPermissions, because no one is there to click "allow";
#   - ONLY the artifact tools plus Read / Write / Edit / Glob / Grep allowed, and Bash + all web tools denied, so it can't
#     run programs or reach other websites. Fixed rules (below) keep its files inside work/ and forbid deleting artifacts
#     or changing who they're shared with.
#
# Settings (environment variables, all optional):
#   BRIDGE_MODEL  model to use (default: sonnet)
#   BRIDGE_TURNS  most tool turns per request (default: 60)
#   CLAUDE_BIN    path to the claude command (default: found on PATH, or ~/.local/bin/claude)
set -u
B="${0:A:h}"                                   # the folder this script is in (zsh: absolute path, then its head)
NAME="${1:?usage: zsh bridge.sh <request name, without .md>}"
REQ="$B/requests/$NAME.md"; OUT="$B/results/$NAME"
[ -f "$REQ" ] || { echo "BRIDGE_FAIL no request file $REQ"; exit 2; }
mkdir -p "$B/results" "$B/work"
export PATH="$HOME/.local/bin:$PATH"
CLAUDE="${CLAUDE_BIN:-$(command -v claude)}"
[ -x "$CLAUDE" ] || { echo "BRIDGE_FAIL Claude Code isn't installed: curl -fsSL https://claude.ai/install.sh | bash"; exit 3; }
# not signed in -> stop early with a clear message instead of a confusing failure half way
"$CLAUDE" auth status 2>/dev/null | grep -q '"loggedIn": true' || { echo "BRIDGE_FAIL Claude Code isn't signed in: run login.command (double-click) or 'claude auth login'"; exit 3; }
cd "$B"   # a folder with no project files, so the run doesn't pick up some repo's CLAUDE.md or settings

# The fixed rules put in front of every request. Edit to taste, but keep the last line: callers look for it.
RULES="You are an artifact bridge running on the owner's own computer. A Claude chat that can't edit these artifacts itself wrote the request below. Do exactly what it asks with your artifact tools, nothing more. Read local files it names with Read. Before writing to a database document that already exists, read it to get its version. To change a page: get its current content, keep your working copy and any edits inside $B/work, change only what the request says, and republish to the SAME artifact (never create a new one unless asked); keep its title, sharing and declared capabilities. Never delete an artifact or change who it is shared with. Never write files outside $B/work. If anything is unclear or refused, stop and say so. End your answer with one line: BRIDGE_RESULT: OK (what you changed) or BRIDGE_RESULT: FAIL (why).

REQUEST:
"
CLAUDE_CODE_ARTIFACT=1 "$CLAUDE" -p "$RULES$(cat "$REQ")" \
  --model "${BRIDGE_MODEL:-sonnet}" --max-turns "${BRIDGE_TURNS:-60}" --output-format json \
  --permission-mode bypassPermissions \
  --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Artifact" "ArtifactData" "ArtifactComments" "ArtifactCheck" "mcp__claude-artifacts" \
  --disallowedTools "Bash" "NotebookEdit" "WebFetch" "WebSearch" \
  > "$OUT.json" 2> "$OUT.err"
RC=$?
# pull Claude's final answer out of the JSON (falls back to the error output if the run didn't finish)
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("result",""))' "$OUT.json" > "$OUT.txt" 2>/dev/null || cp "$OUT.err" "$OUT.txt"
echo "exit $RC"; tail -3 "$OUT.txt"
grep -q "BRIDGE_RESULT: OK" "$OUT.txt" && { echo BRIDGE_OK; exit 0; } || { echo BRIDGE_NOT_OK; exit 1; }
