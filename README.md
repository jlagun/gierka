# Bursa Tales

Bursa Tales is a co-op first-person shooter for up to 8 players. A mysterious event has teleported a Polish high-school dorm (a *bursa*) into hell, and its former residents have to fight their way out. It's a hobby project by jlagun and bionosal, made with Godot 4.7.

**Status:** milestone M0. Players can join a dedicated server and see each other move in a test arena. What comes next is in the [roadmap](docs/ROADMAP.md).

## What you need

- **Godot 4.7.2**, the standard build (not .NET), [downloaded directly](https://godotengine.org/download/archive/4.7.2-stable/). Avoid the Steam version: it updates itself, and you both need exactly the same version.
- **Git LFS,** for binary assets like sounds. On macOS, install it with `brew install git-lfs` (Git for Windows already includes it), then run `git lfs install` once. Without it, a sound arrives as a 130-byte text file that Godot can't load.
- **Tailscale,** to play together over the internet without port forwarding.

Tell the scripts where Godot is, using the `GODOT` environment variable:

- **macOS:** add `export GODOT=/Applications/Godot.app/Contents/MacOS/Godot` to `~/.zshrc`.
- **Windows:** in PowerShell, run this once, then open a new terminal:

  ```powershell
  [Environment]::SetEnvironmentVariable('GODOT', 'C:\path\to\Godot_v4.7.2-stable_win64_console.exe', 'User')
  ```

## Run it

**From the editor:** open `game/project.godot` in Godot and click the Run Project button (▶, top right). The shortcut is F5 on Windows and Cmd+B on macOS. In the main menu:

- **Host** starts a server on your computer and lets you play on it.
- **Join** connects to someone else's server.

To try multiplayer on your own, use Debug → Customize Run Instances and run 2 instances.

**From the command line:**

| | macOS | Windows |
|---|---|---|
| Game with the main menu | `tools/run_client.sh` | `powershell -ExecutionPolicy Bypass -File tools\run_client.ps1` |
| Join a server right away | `tools/run_client.sh --connect 100.64.0.1 --name Kuba` | the same options, after `run_client.ps1` |
| Dedicated server | `tools/run_server.sh` | `powershell -ExecutionPolicy Bypass -File tools\run_server.ps1` |
| Smoke test | `tools/smoke_test.sh` | `powershell -ExecutionPolicy Bypass -File tools\smoke_test.ps1` |

The game understands these options:

- `--server`: run a dedicated server
- `--host`: run a server and play on it
- `--connect <address>`: join a server right away
- `--port <port>`: the UDP port, 7777 by default
- `--name <nickname>`: your nickname

## Play together over Tailscale

1. Both of you install Tailscale. One of you invites the other to your tailnet, or shares the host computer with them.
2. The host starts a dedicated server with `tools/run_server.sh` and then the game, or just clicks **Host** in the main menu.
3. The host finds their Tailscale address with `tailscale ip -4`. It starts with `100.`.
4. The other player types that address in the main menu and clicks **Join**.

The first time a server starts, macOS or Windows may ask whether Godot can accept incoming connections. Allow it.

## Controls

- WASD: move
- Shift (hold): sprint, while moving forward
- mouse: look around
- left click: shoot
- R: reload
- Space: jump
- Esc: free the mouse (click to capture it again)

## Tests and CI

Every pull request runs these checks on GitHub, and you can run them yourself before you push:

- **Unit tests (GUT):** `tools/run_tests.sh`. The tests are in `game/tests/unit`.
- **Warnings:** `tools/check_warnings.sh` fails if a script has a Godot warning.
- **Format and style:** `gdformat --check` and `gdlint`, from [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) (`pip install gdtoolkit==4.5.0`).
- **Smoke test:** see below.

The pull request template asks for a "how to test" section. CI must be green before a pull request can be merged.

## Smoke test

The smoke test starts a dedicated server and two bot clients, without windows. The bots walk in circles and shoot now and then. The test passes when each bot has seen the other one move, and nothing logged an error or a warning. Run it before you push.

## Documentation

- [CLAUDE.md](CLAUDE.md): tech stack, project structure, conventions and git workflow
- [docs/DESIGN.md](docs/DESIGN.md): the game design
- [docs/ROADMAP.md](docs/ROADMAP.md): milestones and tasks
