Artifact: My Team Hub, https://claude.ai/artifact/XXXXXXXXXXXXXXXXXXXXXX. Database writes only, no page change.

First read items/ABC-0001 to copy the field shape, and check items/ABC-0002 doesn't exist yet (if it does, stop and report).
Then write:
1. items/ABC-0002 = {"code":"ABC-0002","title":"Export button greyed out on Safari","kind":"problem","urgency":"high","summary":"...","details":["..."],"doneWhen":"..."}
2. admin/triage/items/ABC-0002 = {"status":"new"}  (merge if it exists)
3. activity/abc-0002-new = {"type":"new","code":"ABC-0002","title":"Export button greyed out on Safari","at":1700000000000}

Read items/ABC-0002 and admin/triage/items/ABC-0002 back and confirm.
