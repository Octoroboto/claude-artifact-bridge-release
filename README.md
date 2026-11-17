# claude-artifact-bridge

**Version 1.0.0** · Let a Claude chat update claude.ai artifacts it isn't allowed to change, by passing the change to Claude Code on your own computer.

## The problem
In some Claude chats (for example cloud Cowork chats or project chats in an organization with network egress turned off), the artifact tools refuse to change an artifact that the chat didn't create itself:

```
network_off: Network access is off and this session did not make this artifact, so tools here can't change or delete it.
```

That blocks the everyday jobs: adding a ticket to a hub page's database, updating an install guide, republishing a dev guide. A chat opened from the artifact's own page can still edit it, but that's a manual step every time.

## The idea
Artifacts belong to your **claude.ai account**, not to the chat that made them. **Claude Code running on your own computer**, signed in to the same account, can update any artifact your account owns or can edit. So the chat writes down exactly what it wants changed, and a small script runs Claude Code headless on your computer to make the change.

```
cloud chat ──writes──▶ requests/<name>.md ──▶ bridge.sh (claude -p, artifact tools only) ──▶ artifact updated
     ▲                                                                                        │
     └──────────────────────────── reads results/<name>.txt ◀─────────────────────────────────┘
```

The chat needs some way to put a file on your computer and read one back. In Claude's desktop app that's a connected folder (the chat's shell on your computer, or its file tools). It also needs a way to start the script: a job runner you already have, or `watch.sh` from this repo.

## Setup (macOS, about 5 minutes)
1. Put this folder somewhere the chat can reach, for example inside a folder you've connected to Claude.
2. Double-click **login.command** once. It installs Claude Code if needed and signs it in. Pick the claude.ai account that owns the artifacts.
3. Start the watcher in Terminal and leave it open: `zsh watch.sh`. Skip this if you already have a job runner; then run `zsh bridge.sh <name>` from it.
4. Add the standing instruction in **PROJECT_INSTRUCTION.md** to your Claude project's instructions, so every chat knows to use the bridge.

Linux works the same way, but run `claude auth login` yourself instead of the `.command` file.

## Using it
A request is a plain-language markdown file in `requests/`. Name the artifact by its URL and say exactly what to change. The examples folder has three:

| Example | What it does |
|---|---|
| `examples/db-write.md` | adds and updates documents in an artifact's database (tickets, statuses) |
| `examples/page-edit.md` | edits text and sections of a page and republishes it to the same URL |
| `examples/republish-file.md` | republishes a finished HTML file from your computer (e.g. a generated dev guide) |

The result lands in `results/<name>.txt`. Its last line is `BRIDGE_RESULT: OK (...)` or `BRIDGE_RESULT: FAIL (...)`, and `results/<name>.json` has the full run (cost, turns, session id).

## Safety
- The run allows **only** the artifact tools plus Read / Write / Edit / Glob / Grep. **Bash and all web tools are denied**, so it can't run programs or reach other websites.
- It runs with `bypassPermissions` because nobody is there to click "allow". The tool list above is what keeps that safe.
- Fixed rules come before every request:
  - do only what's asked;
  - read a database document's version before writing it;
  - republish pages to the same artifact, keeping their title, sharing and capabilities;
  - never delete an artifact or change who it's shared with;
  - keep working files inside `work/`.
- Only you and Claude chats you've given access to that folder can write requests. Treat `requests/` like a command queue.
- Requests can contain whatever the chat writes into them. Don't run requests from people you don't trust.

## Cost and limits
- Each request is a normal Claude Code run on your plan, so a small database change costs about as much as a short chat. Page edits on big pages cost more. Set `BRIDGE_MODEL` / `BRIDGE_TURNS` to tune it.
- Your computer must be on, with the watcher (or your job runner) running.
- Needs Claude Code 2.1.322 or later: `CLAUDE_CODE_ARTIFACT=1` turns the artifact tools on in `claude -p` runs.

## Files
| File | What it is |
|---|---|
| `bridge.sh` | runs one request: `zsh bridge.sh <name>` |
| `watch.sh` | runs every new request in `requests/`, one at a time |
| `login.command` | one-time install + sign-in (double-click) |
| `PROJECT_INSTRUCTION.md` | the standing instruction to paste into a Claude project |
| `examples/` | request templates |
| `requests/`, `results/`, `work/` | the queue, the answers and the bridge's scratch space (not in git) |

MIT licence. Not an official Anthropic tool. It uses Claude Code's documented headless mode and artifact tools.
