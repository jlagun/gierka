<!-- Name the branch <github-username>/<issue-number>-<short-slug>, and keep the PR small. -->

Closes #

## What changed

<!-- A short list of the files or folders, and what each change does. -->

## How to test

<!-- Exact steps, so the other person can try it on their own machine. For example:
1. `git fetch origin`, then `git checkout <branch>`
2. Run the smoke test: `tools/smoke_test.sh` (macOS) or
   `powershell -ExecutionPolicy Bypass -File tools\smoke_test.ps1` (Windows)
3. Open `game/project.godot`, run the project and click **Host**
4. What to try, and what you should see
-->

## Crossing areas

<!-- If this touches the other person's area, say so here, so that its owner reviews it.
Network changes (a new RPC, a synced property or a change of authority) need bionosal's review.
Write "None" if it doesn't. -->

## Screenshot or clip

<!-- For anything visible. Delete this section if there's nothing to see. -->

## Checklist

- [ ] It runs from the editor, and with a dedicated server and two clients if it's a network feature
- [ ] No new warnings (Godot or gdlint), and CI is green
- [ ] DESIGN.md, ROADMAP.md or CLAUDE.md are updated, if a decision or a convention changed
- [ ] Tested on macOS and Windows, or I say below which one is still missing
