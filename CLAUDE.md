# Bursa Tales

Bursa Tales is a co-op first-person shooter for up to 8 players, set in a Polish high-school dorm that got teleported to hell. Two hobby developers work on it, about 8 hours a week each. It's built with Godot 4.7.2 and statically typed GDScript.

Claude Code reads this file at the start of every session, on both machines. Keep it short and current.

## Where things are

| What | Where | Rule |
|---|---|---|
| What we build: the agreed design and the decision log | [docs/DESIGN.md](docs/DESIGN.md) | Source of truth for the game design. |
| What's next: milestones and who does what | [docs/ROADMAP.md](docs/ROADMAP.md) | Update the milestone status when one finishes. |
| Tasks | GitHub issues | One issue per task, with one assignee. |
| Tech, structure, conventions, workflow | this file | Update it in the same PR whenever a convention changes. |
| The original brief | [docs/GAME_DESIGN_PROMPT.md](docs/GAME_DESIGN_PROMPT.md) | Frozen. Never edit it. |
| The step-1 review and the options we considered | [docs/archive/](docs/archive/) | Historical. Never edit it. |
| Reference material | [docs/reference/](docs/reference/) | For example, the floor plan of the real bursa. |

## Team and ownership

| | GitHub | Machine | Owns |
|---|---|---|---|
| Player 1 | `jlagun` | macOS | **Client and feel:** player movement and physics, weapons and how shooting feels, demon behavior and animation, levels (the bursa map), visuals and shaders, HUD, audio |
| Player 2 | `bionosal` | Windows | **Server and world:** networking, the dedicated server, game rules on the server (waves, spawning, damage, score), saving, builds, CI/CD and deployment, main menu and connect flow |

- **Shared areas:** story, NPCs, quests, balance and art direction.
- **The owner of an area decides.** In shared areas, each person writes a preference in the issue. If they still disagree after one discussion, pick the cheaper or more reversible option and log it in the DESIGN.md decision log.
- **Crossing areas:** if a change touches the other person's area, say so in the PR description so that its owner reviews it.

## Tech stack

- **Engine:** Godot **4.7.2** stable, the standard build (not .NET).
  - Both players and CI use exactly this version, and upgrade together in a PR of their own.
  - Download it from <https://godotengine.org/download/archive/4.7.2-stable/>.
  - Avoid the Steam version, because it auto-updates.
- **Language:** GDScript, with static types everywhere.
- **Rendering:** the Forward+ renderer. Switch to Compatibility only if a machine can't run Forward+.
- **Physics:** Jolt, Godot's built-in 3D physics option, set explicitly in the project settings.
- **Networking:** Godot's high-level multiplayer: `ENetMultiplayerPeer` (UDP), `@rpc`, `MultiplayerSpawner` and `MultiplayerSynchronizer`.
  - The default port is UDP 7777.
  - netfox (an add-on for prediction and lag compensation) may come later. Don't add it without a decision.
- **Dedicated server:** the same project, run without a window (`--headless`). After v0.1 it runs as a Linux export in Docker on a VPS.
- **Playing over the internet during development:** Tailscale. Connect to the host's Tailscale IP, so nobody has to set up port forwarding.
- **Tests:**
  - GUT (Godot Unit Test) for unit tests. The add-on is in `game/addons/gut` and the tests are in `game/tests/unit`, one `test_*.gd` file per class. Test names say what they check, like `test_clean_nickname_cuts_a_long_name`.
  - A headless smoke test that starts a server and two bot clients.
  - A warnings check, which fails if any script has a Godot warning.
  - All of them run in CI.
- **Lint and format:** `gdlint` and `gdformat` from gdtoolkit (Python). If they can't parse newer GDScript syntax, rely on Godot's own warnings and note it in the PR.
- **CI:** GitHub Actions, in `.github/workflows/ci.yml`. Every pull request runs `gdformat --check`, `gdlint`, the GUT tests, the warnings check and the smoke test, on Linux with Godot 4.7.2. When you upgrade Godot or gdtoolkit, change the version in `ci.yml` too (and the checksum of the Godot download).
- **Assets:** CC0 packs (Kenney, Quaternius, Poly Pizza) and Mixamo animations.
  - Every third-party asset is listed in `game/assets/CREDITS.md`.
  - The repository is public, so only commit assets whose license allows sharing them. CC0 is always fine. Check Mixamo's terms before committing Mixamo files.
  - Binary assets under `game/assets/` go through Git LFS.
- **Claude Code cloud sessions** (claude.ai/code): a SessionStart hook, `.claude/hooks/session-start.sh`, installs Godot and gdtoolkit when a cloud session starts. That lets the session run the smoke test and the linters. On your own machines the hook does nothing. When you upgrade Godot, change the version in that script too.

## Project structure

This is the target layout. M0 created `main/`, `net/`, `player/`, `levels/`, `ui/`, `tests/`, `assets/` and `tools/`, M1.2 added `weapons/`, and M2.1 added `demons/`. The other folders appear with the first task that needs them.

```
CLAUDE.md
docs/                  design, roadmap, reference, archive
game/                  the Godot project: open game/project.godot
  main/                boot: starts a server, host or client depending on command-line arguments
  net/                 networking autoload, connect flow, player registry
  player/              first-person controller and the player scene
  weapons/             weapon scenes and scripts, weapon data (.tres)
  demons/              demon scenes and AI, demon data (.tres)
  rules/               game rules on the server: waves, damage, score
  levels/              test arena, the bursa
  ui/                  main menu, HUD, translations
  assets/              third-party models, textures, audio + CREDITS.md (Git LFS)
  tests/               GUT unit tests, smoke test
  addons/              third-party Godot add-ons (GUT)
deploy/                Dockerfile and server deployment
tools/                 scripts to run a server and clients locally, and the smoke test
.github/               CI workflows, PR template
```

- **Organize by feature.** A scene and its script live side by side.
- **Content is data.** Weapons and demons are `Resource` subclasses saved as `.tres` files, so a new weapon is mostly new data.

## Running the game

Put your Godot executable in the `GODOT` environment variable, or on your `PATH` as `godot`:

- **macOS:** `/Applications/Godot.app/Contents/MacOS/Godot`
- **Windows:** `Godot_v4.7.2-stable_win64_console.exe`. The console build prints output to the terminal.

| | macOS (bash) | Windows (PowerShell) |
|---|---|---|
| Game with the main menu | `tools/run_client.sh` | `tools\run_client.ps1` |
| Dedicated server (UDP 7777) | `tools/run_server.sh` | `tools\run_server.ps1` |
| Smoke test: a server and two bots | `tools/smoke_test.sh` | `tools\smoke_test.ps1` |
| Unit tests (GUT) | `tools/run_tests.sh` | see below |
| Warnings check | `tools/check_warnings.sh` | see below |

- **Running the PowerShell scripts:** Windows blocks scripts by default, so run them as `powershell -ExecutionPolicy Bypass -File tools\smoke_test.ps1`.
- **Unit tests and the warnings check on Windows:** there are no PowerShell scripts for these, because CI runs them for every pull request. To run the tests yourself, run `& $env:GODOT --headless --path game --import` once, then `& $env:GODOT --headless --path game -s addons/gut/gut_cmdln.gd`. The warnings check needs bash, so use WSL or let CI do it.
- **Game options** come after `--`: `--server`, `--host`, `--connect <address>`, `--port <port>`, `--name <nickname>`, and `--bot` for the smoke test. For example, `$GODOT --headless --path game -- --server`. In PowerShell, write `& $env:GODOT` and quote the separator as `'--'`, or PowerShell may swallow it.
- **A fresh clone must be imported once** before the game can start from the command line: `$GODOT --headless --path game --import`. The scripts do this for you, and so does opening the project in the editor.
- **Several instances from the editor:** use Debug → Customize Run Instances.
- **In a cloud session without Godot installed:** say so. Never claim the game runs without running it.

## Coding conventions

- **Style:** follow the official GDScript style guide.
  - Files, folders, functions and variables are `snake_case`.
  - `class_name` and node names are `PascalCase`.
  - Constants are `CONSTANT_CASE`.
  - Signals are named in the past tense (`health_changed`, `died`).
  - Private members start with `_`.
- **Static types everywhere:** for example `var speed: float = 5.0` and `func take_damage(amount: int) -> void:`. The project setting `debug/gdscript/warnings/untyped_declaration` is set to Error.
- **Godot 4 syntax only.** These Godot 3 leftovers don't work:

  | Godot 3 | Godot 4 |
  |---|---|
  | `export var` | `@export var` |
  | `onready` | `@onready` |
  | `yield` | `await` |
  | `KinematicBody` | `CharacterBody3D` |
  | `instance()` | `instantiate()` |
  | `connect("signal", obj, "method")` | `signal.connect(method)` |
  | `remote`, `master`, `puppet` | `@rpc(...)` |
  | `rand_range` | `randf_range` |

- **Signals vs calls:** use signals for "something happened", and direct method calls for "do this".
- **No magic numbers in gameplay code.** Tunable values are `@export` variables or live in `.tres` data.
- **No new warnings.** Fix warnings rather than silencing them. If one really must be ignored, use `@warning_ignore` with a comment saying why. The editor shows warnings in the script editor. On the command line, Godot only prints warnings that are set to Error, so a clean headless run doesn't prove there are none.
- **Player-facing text** goes through `tr()`, with the English text itself as the key: `tr("Could not connect to the server.")`. Text typed into scenes is translated automatically. A Polish translation can be added later as a `.po` file, without code changes.
- **Comments and language:** comments explain *why*, not *what*. Code, comments, commits, issues and docs are in English.
- **Prefer Godot's built-in nodes** over custom systems: `NavigationAgent3D` for pathfinding, `AnimationTree` for animation, `MultiplayerSpawner` and `MultiplayerSynchronizer` for replication.

## Networking rules

Player movement belongs to both owners, so this section is how their code fits together. The model is described in DESIGN.md (decision D14).

- **The server is the authority** for demons, health, damage, deaths, respawns, waves and score. Clients never change these directly.
- **Each client is the authority** for its own player's movement and aim. It gets this through `set_multiplayer_authority(peer_id)` on the player node, and the position replicates through a `MultiplayerSynchronizer`.
- **Shooting:**
  1. The shooter's client does the raycast and sends a hit claim to the server over RPC.
  2. The server checks the claim (fire rate, range, whether the target is alive) and applies the damage.
  3. Effects like muzzle flashes and tracers are cosmetic RPCs.
- **Making something damageable:** put `rules/health.tscn` under the node that can be hurt. The node then joins the group `damageable`, and its `Health` replicates to every client. The server stays the authority for `Health` even under a node a client owns, like a player. Only the server calls `Health.apply_damage()`. The server decides hits in `rules/hit_claims.gd`; the rules are in D25 in DESIGN.md.
- **Spawning:** only the server spawns networked nodes, and always through a `MultiplayerSpawner`. Node names are unique and deterministic; player nodes are named after their peer id.
- **RPCs:** declare every RPC explicitly, for example `@rpc("any_peer", "call_remote", "reliable")`. An `any_peer` RPC must check `multiplayer.get_remote_sender_id()` before acting.
- **The server has no screen.** It loads the same scenes but runs headless. So cameras, input, audio and UI must only run on the client that owns them.
- **Network changes need bionosal's review.** That includes any new synced property, new RPC or change to authority.

## Git workflow

- **`main` always runs, and nobody pushes to it directly.** Every change goes through a pull request. The repository is public, so GitHub can enforce this: `main` requires a pull request with one approval, and passing CI once CI exists (M1.7).
- **The repository is public, so never commit secrets.** That includes tokens, SSH keys, passwords, Tailscale auth keys and the VPS address. CI secrets go in GitHub Actions secrets.
- **One issue per task, with one assignee.** Name the branch after the issue: `<github-username>/<issue-number>-<short-slug>`, for example `jlagun/12-shotgun` or `bionosal/7-dedicated-server`. The exception is Claude Code cloud sessions: they work on an auto-named `claude/…` branch, which is fine, because the PR's `Closes #<issue>` links it to the issue.
- **CI must be green to merge.** The check is called `checks`, and it is required in the `main` ruleset (GitHub → Settings → Rules). A pull request with a warning or a failing test is blocked.
- **Small PRs, reviewed by the other person, squash-merged.** Each PR becomes one commit on `main`.
- **Commit messages follow Conventional Commits:**
  - prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`
  - an imperative subject of 72 characters or less
  - the PR description says `Closes #<issue>`
- **The PR description says what changed and how to test it,** with exact steps. Add a screenshot or a short clip for anything visible.
- **Git LFS:** run `git lfs install` once per machine. Binary files under `game/assets/` go through LFS (set up in `.gitattributes`).
- **What to commit:**
  - Never commit `.godot/` or exported builds.
  - Do commit the `*.import` files, the `*.uid` files and `export_presets.cfg`.

## Definition of done

A task is done when all of these are true:

1. **It runs.**
   - It works from the editor.
   - Network features also work with a dedicated server and two clients.
2. **The other person has played it at least once**, in the weekly playtest or in an extra session. Because they're on the other operating system, every change gets tested on both macOS and Windows.
3. **Nothing new is flagged.** There are no new warnings (Godot or gdlint), and CI is green.
4. **The docs are current.** If the task changed a decision or a convention, DESIGN.md or this file is updated in the same PR.

## Working in this repo with Claude Code

- **Start from the task:** read the issue, the relevant parts of docs/DESIGN.md and the current milestone in docs/ROADMAP.md.
- **Stay within the issue's scope.** New ideas go into the issue or the DESIGN.md backlog, not into the code.
- **Before pushing:**
  - Run the unit tests (`tools/run_tests.sh`), the warnings check (`tools/check_warnings.sh`) and the headless smoke test (a server plus two clients).
  - Fix new warnings.
  - Follow the git workflow above.
- **In a cloud session you can't open a window, so you can't playtest.** When a task is done, tell the player which branch to check out on their own machine and what to try. The definition of done needs someone to play it.
- **Record changes where they belong:**
  - decisions go in the DESIGN.md decision log, using the next free D-number
  - conventions go in this file
  - milestone progress goes in ROADMAP.md
- **Respect the hard "no" list** in DESIGN.md section 11. Don't add accounts, matchmaking, mods, anti-cheat, in-game voice, generated levels, a custom engine or physics, realistic graphics, or store releases.
