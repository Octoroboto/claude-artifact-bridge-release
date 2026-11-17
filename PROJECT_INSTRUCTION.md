# Standing instruction (paste into your Claude project's instructions)

Replace <BRIDGE> with where this folder is on your computer (as your chats see it).

```
Artifact bridge: if changing an EXISTING artifact (database writes, page edits, republishing) is refused with
"network_off ... this session did not make this artifact", don't stop and don't hand me a payload. Instead:
1. write a request to <BRIDGE>/requests/<new-unique-name>.md: the artifact's URL, exactly what to change (for database
   writes the paths and JSON; for pages the exact edits or the path of a finished HTML file on my computer), and
   "read it back to confirm";
2. if a job runner isn't set up, the watcher picks it up automatically (otherwise start: zsh <BRIDGE>/bridge.sh <name>);
3. read <BRIDGE>/results/<name>.txt - the last line is BRIDGE_RESULT: OK or FAIL - and tell me what changed.
New artifacts are still made in the chat as usual; the bridge is only for artifacts made elsewhere.
```
