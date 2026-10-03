# Bursa Tales: roadmap

> **Status, 2026-10-03:** approved by jlagun and bionosal. Every task has a GitHub issue, and each task number below links to it. The issues are labeled with their milestone (`M0` to `M5`) and assigned to their owners. M0 is done: you played it together over Tailscale, and the smoke test passes on both machines. M1 is in progress: M1.2 is merged, and M1.1, M1.3, M1.4 and M1.7 are in review. Two M2 tasks started early: the crosshair and ammo part of M2.7, and M2.1.
>
> Where v0.1 is headed is described in [DESIGN.md](DESIGN.md), section 7. Who owns what, and how to work, is in [CLAUDE.md](../CLAUDE.md).

## How this roadmap works

- **Every milestone ends with a playtest.** The two of you play it together on Discord, each on your own machine. If it's broken or not fun, fix that before starting the next milestone.
- **Each task is one GitHub issue**, assigned to the owner of its area (see CLAUDE.md). The task numbers in the tables link to the issues.
- **Tasks in a milestone can run in parallel**, unless the "Needs" column lists another task first.
- **Sizes:** S is up to 2 hours, M is 2–5 hours, and L is 5–8 hours. At about 8 hours a week each, a milestone takes 1–2 weeks.
- **Timeline:** v0.1 is the end of M4, about 2 months from now. M5 then puts it on a server that's always online.

## Overview

| Milestone | At the playtest you can… | Weeks |
|---|---|---|
| [M0 Hello world](#m0-hello-world) | walk around a test arena together and see each other move | 1 |
| [M1 Shooting together](#m1-shooting-together) | shoot target dummies together | 1–2 |
| [M2 Demons](#m2-demons) | fight demons that chase you, die and respawn | 1–2 |
| [M3 The bursa](#m3-the-bursa) | fight demons in a graybox of the real bursa | 1–2 |
| [M4 Waves: v0.1](#m4-waves-v01) | survive growing waves and beat your best wave | 1–2 |
| [M5 Online](#m5-online) | play v0.1 from home on a server that's always on | 1–2 |

## M0: Hello world

**Goal:** two clients connect to one dedicated server and see each other move.

**Playtest:**
- jlagun (macOS) runs the dedicated server and a client.
- bionosal (Windows) joins over Tailscale.
- You both walk around the test arena and see each other's capsules with nicknames above them.
- The headless smoke test passes on both machines.

**How it's built:**
- M0.1 is jlagun's.
- Claude builds M0.2–M0.8 as one pull request, which is the project scaffold.
- In the review, bionosal checks the networking parts and jlagun checks the player and arena. Both approve before merging. Reading it closely is the best way to learn the codebase.

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M0.1](https://github.com/jlagun/gierka/issues/2) | Repo setup. Claude creates `main` from the approved docs. jlagun makes it the default branch (GitHub → Settings → General → Default branch) and protects it (Settings → Rules: require a pull request with one approval). Then jlagun deletes the old `claude/*` branches once they're merged. | jlagun | S | – |
| [M0.2](https://github.com/jlagun/gierka/issues/3) | Godot project in `game/`: the folder structure from CLAUDE.md, and project settings (untyped code is an error, Jolt physics, input map). Also `.gitignore`, `.gitattributes` for Git LFS, and a README with how to run the game. | Claude | M | M0.1 |
| [M0.3](https://github.com/jlagun/gierka/issues/4) | Networking autoload: start a server, connect, disconnect, and keep a registry of players (peer id → nickname). Command-line options `--server`, `--host`, `--connect`, `--name` and `--port`. | Claude | M | M0.2 |
| [M0.4](https://github.com/jlagun/gierka/issues/5) | Main menu: server address, nickname and a Join button, plus a Host button for quick local tests. | Claude | S | M0.3 |
| [M0.5](https://github.com/jlagun/gierka/issues/6) | Player: a first-person capsule (`CharacterBody3D`) with WASD, mouse look and jump. Camera and input only for your own player. A nickname label above the head. | Claude | M | M0.2 |
| [M0.6](https://github.com/jlagun/gierka/issues/7) | Spawning and sync. The server spawns a player for each connection and removes it on disconnect. Each client moves its own player, and positions replicate to everyone. | Claude | M | M0.3, M0.5 |
| [M0.7](https://github.com/jlagun/gierka/issues/8) | Test arena: floor, walls, a few boxes and light. | Claude | S | M0.2 |
| [M0.8](https://github.com/jlagun/gierka/issues/9) | Run scripts for starting a server and clients locally: bash for macOS, PowerShell for Windows. A headless smoke test: a server and two bot clients that check they can see each other move. | Claude | M | M0.6 |
| [M0.9](https://github.com/jlagun/gierka/issues/10) | Install Godot 4.7.2, Git LFS and Tailscale, then run the playtest. | both | S | M0.2–M0.8 |

## M1: Shooting together

**Goal:** movement that feels good, and a pistol. Hits count on the server, everyone sees everyone's shots, and CI checks every pull request.

**Playtest:**
- You shoot target dummies together in the arena.
- You both see each other's shots, and the dummies' health going down.
- The other player moves smoothly, without jitter.

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M1.1](https://github.com/jlagun/gierka/issues/11) | Movement feel: acceleration, friction, jump height and sprint. The tuning values live in data. | jlagun | M | – |
| [M1.2](https://github.com/jlagun/gierka/issues/12) | Weapon system: a `WeaponData` resource (damage, fire rate, range, spread, pellets, magazine size, reload time). A weapon node with a hitscan raycast. The pistol, with ammo and reloading. | jlagun | L | – |
| [M1.3](https://github.com/jlagun/gierka/issues/13) | Shot effects everyone sees: muzzle flash, tracer and impact, plus a pistol sound (CC0). | jlagun | M | M1.2 |
| [M1.4](https://github.com/jlagun/gierka/issues/14) | Hit claims. The shooter sends an RPC to the server, and the server checks fire rate, range and target before applying damage. A `Health` component that replicates to clients. | bionosal | M | M1.2 |
| [M1.5](https://github.com/jlagun/gierka/issues/15) | Target dummies with health, owned by the server. They respawn after being destroyed. | bionosal | S | M1.4 |
| [M1.6](https://github.com/jlagun/gierka/issues/16) | Smooth remote players: interpolate their replicated positions (a buffer of about 100 ms). | bionosal | M | – |
| [M1.7](https://github.com/jlagun/gierka/issues/17) | CI on GitHub Actions for every pull request. It imports the project headless, then runs the gdlint and gdformat checks, the GUT tests and the smoke test, and fails on new warnings. Also a PR template with a "how to test" section. | bionosal | L | – |

## M2: Demons

**Goal:** demons chase and attack players, and players have health, die and respawn.

**Playtest:**
- In the arena, a pack of demons chases you both.
- You shoot them down together, die, and respawn after about 5 seconds.
- Someone who joins in the middle of a fight sees everything correctly.

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M2.1](https://github.com/jlagun/gierka/issues/18) | Demon: a placeholder model and animations from a CC0 pack. A `DemonData` resource (health, speed, damage, attack range, cooldown). | jlagun | M | – |
| [M2.2](https://github.com/jlagun/gierka/issues/19) | Demon AI, running on the server: chase the nearest player with `NavigationAgent3D` and attack in melee. A navmesh for the arena. | jlagun | L | M2.1 |
| [M2.3](https://github.com/jlagun/gierka/issues/20) | Demon spawning and sync. The server spawns demons through a `MultiplayerSpawner`, replicates their position and animation state, and removes dead ones. | bionosal | M | – |
| [M2.4](https://github.com/jlagun/gierka/issues/21) | Player health, damage from demons, death, and respawn at a spawn point after about 5 seconds. | bionosal | M | – |
| [M2.5](https://github.com/jlagun/gierka/issues/22) | Joining mid-fight: a player who joins late sees the right demons, health and positions. | bionosal | M | M2.3 |
| [M2.6](https://github.com/jlagun/gierka/issues/23) | A friendly-fire server setting, off by default. | bionosal | S | M2.4 |
| [M2.7](https://github.com/jlagun/gierka/issues/24) | HUD: health, ammo, crosshair and hit marker. | jlagun | M | – |
| [M2.8](https://github.com/jlagun/gierka/issues/25) | Demon sounds and a hurt sound for the player (CC0). | jlagun | S | M2.1 |

## M3: The bursa

**Goal:** the game moves from the arena into a graybox of the real bursa ground floor and yard.

**Playtest:** you walk through the bursa together and fight demons in the corridors, the cantine and the yard. Does it feel like your bursa?

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M3.1](https://github.com/jlagun/gierka/issues/26) | Graybox of the ground floor, based on [the floor plan](reference/bursa-ground-floor.png): the entrance and the portier, the corridor to the cantine and the cantine itself, the long corridor with 4 rooms, the mentor room, the stairs (blocked) and the bathroom. Plus the yard. Proportions can be compressed. | jlagun | L | – |
| [M3.2](https://github.com/jlagun/gierka/issues/27) | A navmesh for the bursa, covering the doors and the blocked stairs. | jlagun | S | M3.1 |
| [M3.3](https://github.com/jlagun/gierka/issues/28) | Level data for the server: player spawn points at the portier, the portal in the yard, and demon entry points at the cantine windows and the main entrance. The server loads the level when it starts. | bionosal | M | M3.1 |
| [M3.4](https://github.com/jlagun/gierka/issues/29) | Hell look, first pass: sky, fog, the color palette and a first psychedelic post-processing shader. | jlagun | M | M3.1 |
| [M3.5](https://github.com/jlagun/gierka/issues/30) | Reconnects: a player who drops out can rejoin, and the server survives a client crashing. | bionosal | M | – |
| [M3.6](https://github.com/jlagun/gierka/issues/31) | Load test with 8 bot clients and 30 demons on the bursa map. Measure bandwidth and frame time on both machines, and fix the worst problems (for example, sync rates). | bionosal | M | M3.3 |

## M4: Waves (v0.1)

**Goal:** the full v0.1 loop from DESIGN.md section 7.

**Playtest:** 15 minutes of wave survival together, trying to beat your best wave. **This is v0.1.**

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M4.1](https://github.com/jlagun/gierka/issues/32) | Wave director on the server: waves grow in number and toughness, with a short break between them. Demons come out of the portal and in through the entry points. | bionosal | L | – |
| [M4.2](https://github.com/jlagun/gierka/issues/33) | Two demon variants as data: fast and weak, slow and tanky. Each looks different (size, color). | jlagun | S | – |
| [M4.3](https://github.com/jlagun/gierka/issues/34) | The shotgun as a second weapon (pellets, spread), lying in the mentor room. Picking up and switching weapons. | jlagun | M | – |
| [M4.4](https://github.com/jlagun/gierka/issues/35) | End of a run: it ends when all players are dead at the same moment. Show the wave reached and the best wave, then restart from wave 1. | bionosal | M | M4.1 |
| [M4.5](https://github.com/jlagun/gierka/issues/36) | HUD for waves: the wave number, a "wave N" banner, a countdown during the break, and the best wave. | jlagun | S | M4.1 |
| [M4.6](https://github.com/jlagun/gierka/issues/37) | Portal effect and sound, and a first music track (CC0). | jlagun | S | – |
| [M4.7](https://github.com/jlagun/gierka/issues/38) | Balance pass together: tune the numbers in the `.tres` files during a playtest. | both | S | M4.1–M4.4 |

## M5: Online

**Goal:** v0.1 runs on a rented server that's always online, and you both join from home without Tailscale.

**Playtest:** you play v0.1 on the rented server (a VPS) from home, on both operating systems.

| # | Task | Owner | Size | Needs |
|---|---|---|---|---|
| [M5.1](https://github.com/jlagun/gierka/issues/39) | Export presets: Windows and macOS clients, and the Linux dedicated server. | bionosal | S | – |
| [M5.2](https://github.com/jlagun/gierka/issues/40) | A Dockerfile for the dedicated server, tested by running it locally in Docker. | bionosal | M | M5.1 |
| [M5.3](https://github.com/jlagun/gierka/issues/41) | Rent a VPS (about €4–6 a month), open the UDP port in its firewall, install Docker, and deploy by hand. | bionosal | M | M5.2 |
| [M5.4](https://github.com/jlagun/gierka/issues/42) | Automatic deployment: every merge to `main` builds the server image and deploys it. Client builds are attached to a GitHub release. | bionosal | L | M5.3 |
| [M5.5](https://github.com/jlagun/gierka/issues/43) | Server logs, and an automatic restart after a crash. | bionosal | S | M5.3 |
| [M5.6](https://github.com/jlagun/gierka/issues/44) | The main menu remembers the last server address and nickname. | bionosal | S | – |
| [M5.7](https://github.com/jlagun/gierka/issues/45) | Polish from the M4 playtest: movement feel, effects and sound. | jlagun | M | – |
| [M5.8](https://github.com/jlagun/gierka/issues/46) | Dress the bursa: CC0 props and textures for the ground floor (beds, tables, the cantine counter, the portier's desk). | jlagun | M | – |

## After v0.1 (tentative)

This is a rough order. It gets planned in detail when v0.1 is done, using what you learned in the playtests.

- **v0.2, defend the bursa:**
  - demon currency and the mystery vending machine
  - barricades and turrets you place in first person
  - a projectile weapon and a ranged demon
- **v0.3, the first boss and saving:**
  - a boss fight
  - world saves on the server
  - returning players, recognized by nickname and secret key
  - the world pauses when nobody is online
  - semesters
- **v0.4, the upper floor and old friends:**
  - the upper floor
  - the first NPC friends with simple quests
  - sanity with psychedelic effects
- **Later:** gathering and crafting, the streets around the bursa, the mall, character skills, opt-in PvP duels, and "netcode 2.0".

## Progress

| Milestone | Status | Playtested |
|---|---|---|
| M0 Hello world | done | 2026-09-30 |
| M1 Shooting together | in progress | |
| M2 Demons | in progress | |
| M3 The bursa | not started | |
| M4 Waves (v0.1) | not started | |
| M5 Online | not started | |
