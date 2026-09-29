# Bursa Tales: open decisions

> **Decided on 2026-09-29.** Both players picked A (★) for all 23 decisions. The results are recorded in the decision log of [DESIGN.md](../DESIGN.md). This file is kept as a record of the options you considered. Don't edit it.
>
> The reasoning behind the options is in [DESIGN_REVIEW.md](DESIGN_REVIEW.md).

## Answer table

| # | Decision | ★ | Player 1 | Player 2 | Final |
|---|---|---|---|---|---|
| D1 | One-line pitch | A | A | A | A |
| D2 | What "RTS" means in a first-person game | A | A | A | A |
| D3 | What happens after the boss | A | A | A | A |
| D4 | Co-op or PvP | A | A | A | A |
| D5 | What happens when you die | A | A | A | A |
| D6 | What v0.1 is | A | A | A | A |
| D7 | How big v0.1 is | A | A | A | A |
| D8 | Art style | A | A | A | A |
| D9 | Tone | A | A | A | A |
| D10 | Survival needs (later) | A | A | A | A |
| D11 | The world while nobody is online (later) | A | A | A | A |
| D12 | Loot boxes and grinding (later) | A | A | A | A |
| D13 | Engine and language | A | A | A | A |
| D14 | How the game stays in sync over the network | A | A | A | A |
| D15 | Where the server runs | A | A | A | A |
| D16 | Recognizing returning players (later) | A | A | A | A |
| D17 | Who owns what | A | A | A | A |
| D18 | Tie-breaker for shared areas | A | A | A | A |
| D19 | When you play together | A | A | A | A |
| D20 | Git details | A | A | A | A |
| D21 | One source of truth | A | A | A | A |
| D22 | Hard "no" list | A | A | A | A |
| D23 | Language | A | A | A | A |

| # | Question only you can answer | Answer |
|---|---|---|
| Q1 | Player 2: what do you like doing together in games? (0.2 is blank) | Player 1: fighting, gathering resources and exploring the world. Player 2: teamwork defeating enemies, and having silly fun while playing. |
| Q2 | Which of you is `jlagun` on GitHub, and what is the other person's GitHub username? | jlagun is Player 1 (macOS); bionosal is Player 2 (Windows). |
| Q3 | Optional: can you share a sketch or photos of the real bursa layout? | Yes. The ground-floor layout is in [reference/bursa-ground-floor.png](../reference/bursa-ground-floor.png). The upper floor has more rooms and is not drawn yet. |
| Q4 | Once you approve the roadmap, should Claude create the GitHub issues and milestones and assign them? | Yes (both players). |

---

## Game design

### D1. One-line pitch
*Brief: 1.4 lists reference games but has no "but Z".*

- **A ★** "Rust meets Doom, but you defend your Polish high-school dorm in hell, and your old roommates give the quests."
- **B** "Call of Duty Zombies meets Don't Starve, in a Warsaw bursa teleported to hell."
- **C** "Deep Rock Galactic meets Orcs Must Die!, in a psychedelic Polish hell."

**Why A:** it names your two strongest references and the one thing only your game has: the bursa, with your real friends as NPCs.

### D2. What "RTS" means in a first-person game
*Brief: 1.2 and 0.3 say RTS; 4.2 says 3D first person.*

- **A ★** You build and defend in first person, placing barricades, turrets and traps yourself (like Orcs Must Die!, Sanctum or Rust). There's no commanding of units.
- **B** A, plus an optional top-down map for placing defenses.
- **C** Real RTS: you give orders to squads of NPC friends, RimWorld-style.

**Why A:** a top-down RTS view and a first-person view need two separate sets of controls and interface. A keeps the tower-defense fun without that, and B can be added on top of it later.

### D3. What happens after the boss
*Brief: 5.4 wants a persistent world, 0.3 wants roguelike elements, and 1.2 wants an escape.*

- **A ★** "Semesters." The world persists between sessions until you kill the boss and escape. Then a new semester starts in a fresh, harder hell, and a little progress carries over (rescued friends, cosmetics).
- **B** One endless world, like Valheim or Minecraft. Each boss kill unlocks the next zone, and nothing resets.
- **C** Each session is a new run, like Deep Rock Galactic or Risk of Rain. Only unlocks persist.

**Why A:** you get persistence, a roguelike reset and a real ending, and the resets keep save files small. It doesn't affect v0.1.

### D4. Co-op or PvP
*Brief: 1.2 says co-op; 5.2 says both.*

- **A ★** Co-op only for now. Friendly fire is a server setting, off by default. Optional PvP comes later, for example duels in the bursa gym.
- **B** Co-op with friendly fire on from day one, for pranks and chaos.
- **C** Full PvP, including raiding each other's bases, like Rust.

**Why A:** PvP that feels fair needs lag compensation and balancing. A friendly-fire switch gives you the pranks for about an hour of work.

### D5. What happens when you die
*Brief: not covered.*

- **A ★** You respawn at the bursa after about 5 seconds and keep everything. Later: you drop your demon currency where you died and have to run back for it.
- **B** You drop your whole inventory at your body and have to go back for it (like in Rust or Valheim).
- **C** Roguelike permadeath: the character resets and only unlocks stay.

**Why A:** in v0.1 there is nothing to lose anyway. The later currency drop adds tension without making people quit in anger.

### D6. What v0.1 is
*Brief: 6.1 says flat world and crafting; 6.2 says bursa map; 6.3 puts crafting later.*

- **A ★** Wave survival in the bursa, a small take on Call of Duty Zombies. Demons pour out of a portal in growing waves, and you survive as long as you can. The first 5 minutes:
  1. Type the server address and a nickname.
  2. Spawn in the dorm common room and grab a gun.
  3. The first wave breaks in.
  4. You die and respawn.
- **B** Free roam: demons wander the map, and you explore and hunt them (like Rust or Tibia).
- **C** Exactly what 6.1 says: a flat test world with walking, shooting and basic crafting.

**Why A:** it is the smallest version with tension and a goal. It covers surviving the night (Player 1), and hordes and tower defense (Player 2). Waves are also the starting point for tower defense.

### D7. How big v0.1 is
*Brief: 6.2 lists features without sizes.*

- **A ★**
  - a graybox (untextured blocks) of the bursa ground floor, one dorm corridor and the courtyard
  - two hitscan weapons, meaning the shot hits instantly: a pistol and a shotgun
  - one demon type in two variants: fast and weak, slow and tanky
  - one spawn portal
  - a HUD showing health, ammo and the wave number
- **B** Bigger: the whole building, three weapons including a rocket or plasma launcher, and two demon types (melee and ranged).
- **C** Smaller: a flat arena, one weapon, one demon.

**Why A:** it's enough variety for 15 minutes of laughs. Weapons and demons will be defined as data, so adding more later is cheap. Projectile weapons and ranged demons need extra network work, so they move to v0.2.

### D8. Art style
*Brief: 4.4 points to Schedule I, 1.4 to Doom and Boltgun, and 1.3 says psychedelic.*

- **A ★** Low-poly and stylized like Schedule I, built from free CC0 packs (Kenney, Quaternius, Poly Pizza, Mixamo animations). A hellish color palette and a psychedelic screen shader give it the mood.
- **B** A retro 90s-style shooter like Boltgun or Dusk: low-poly with pixelated textures and low-resolution rendering. Demons could even be flat 2D pictures like in the original Doom, so no 3D animation is needed.
- **C** Voxels, made in MagicaVoxel: easy to make your own models, with simple animation.

**Why A:** free assets exist in bulk, and the psychedelic hell comes from color and shaders you can tune at any time. B's pixel filter can be added on top of A later.

### D9. Tone
*Brief: 1.3 says "tense"; Player 2 wants "fantasy freaking weird shit".*

- **A ★** Doom's tone: tense, fast combat in a weird, psychedelic world, with the humor in the details. Think dorm signs, your NPC friends, and Polish food as power-ups.
- **B** Serious horror: dark, slow and scary.
- **C** Full comedy: absurd from start to finish.

**Why A:** it matches "tense, psychedelic, creative" and leaves room for your inside jokes.

### D10. Survival needs (later)
*Brief: 2.2 says "survival with needs" but never names them.*

- **A ★** Sanity first. It drops in darkness and near demons, and recovers in the bursa. Low sanity brings psychedelic screen effects and fake demons. Hunger comes later, and only if it adds fun.
- **B** Hunger and thirst, the classic Rust needs.
- **C** Health, hunger and sanity, like Don't Starve.

**Why A:** it turns "psychedelic" into a game mechanic, and it fits hell better than a thirst meter.

### D11. The world while nobody is online (later)
*Brief: 5.4 wants a persistent world.*

- **A ★** The world pauses. The server saves and idles, and nothing attacks an empty base.
- **B** The world keeps running, and demons can raid the base while you are offline, like in Rust.
- **C** The world keeps running, but the base can't be damaged while everyone is offline.

**Why A:** in co-op, logging in to a wrecked base is just frustrating. A paused world is also the simplest to build.

### D12. Loot boxes and grinding (later)
*Brief: 0.3. Loot boxes use in-game currency only, since 6.4 bans monetization.*

- **A ★** A mystery vending machine in the bursa. You spend demon currency on a random weapon or upgrade, like the Mystery Box in Call of Duty Zombies.
- **B** Random drops of different rarity from demons and chests, like in Tibia or Diablo.
- **C** Both from the start.

**Why A:** one machine takes a few hours of work and gets big laughs. Add B once there are enough weapons for rarity to matter.

## Tech

### D13. Engine and language
*Brief: 7.1 and 7.2 ask Claude to recommend.*

- **A ★ Godot 4 with statically typed GDScript.**
  - It's free and open source (MIT license), and a small download.
  - It runs natively on Apple Silicon Macs and on Windows, and exports games for Windows, macOS and Linux.
  - It can run without a window as the dedicated server, and it has multiplayer over UDP built in.
  - Its scene files are plain text, which works well with git and with Claude Code, and automated builds (CI) need no license.
  - Downsides: fewer FPS tutorials and assets than Unity. Smoothing out network lag (client prediction and lag compensation) is up to you, or to the netfox add-on.
- **B Unity 6 with C#.**
  - It has the most tutorials and assets, and several networking libraries: Netcode for GameObjects, FishNet and Mirror.
  - It can build a dedicated server.
  - Downsides: a multi-gigabyte editor, and a license login, including in automated builds. Its scene files merge badly in git, and Claude Code can't edit them reliably.
- **C TypeScript with Three.js and a Node.js server.**
  - Everything is code, and the game runs in a browser, so you share a link and nothing needs installing.
  - The server side teaches classic devops: Docker, TLS and WebSockets.
  - Downsides: there's no editor, so you build the map in Blender and write the engine basics yourselves. WebSockets also run over TCP, which is worse than UDP for a fast shooter.

**Why A:** it's the best fit for two hobbyists on macOS and Windows, with a Linux server, a $10 budget and AI-assisted coding.

**Not recommended:** Unreal is huge, saves its visual scripts (Blueprints) as binary files, and is heavy on macOS. Bevy has no mature editor and makes breaking changes in every release.

### D14. How the game stays in sync over the network
*Brief: not covered; this is Player 2's area.*

- **A ★** A hybrid model:
  - Each client moves its own player instantly, so no prediction code is needed.
  - The server owns demons, health, damage and waves.
  - The shooter's client detects hits, and the server checks and applies them.
- **B** The server is in charge of everything from day one, with client-side prediction, reconciliation and lag compensation, as in competitive shooters. This could use netfox, for example.
- **C** One player hosts the game (a "listen server") for v0.1, with a dedicated server later.

**Why A:** it's the fastest route to fun, and cheating doesn't matter between friends. B can become a later "netcode 2.0" milestone for Player 2. In Godot, the same project can run either as a dedicated server or with one player hosting. So C stays available as a free shortcut during development.

### D15. Where the server runs
*Brief: 5.3 wants a dedicated server; 7.4 sets a $10 budget.*

- **A ★** Start local: run the server without a window on one laptop and play over the internet through Tailscale, which is free and needs no router setup. Once v0.1 runs, move to a rented Linux server (a VPS) with Docker, for about €4–6 a month.
- **B** A free cloud tier such as Oracle Cloud Always Free. It costs nothing, but sign-up and availability are a hassle, and it needs ARM builds.
- **C** A computer at home (an old PC or a Raspberry Pi) with port forwarding on the router.

**Why A:** there's no cost while you build. The rented server with Docker, automated builds and deployment (CI/CD) is exactly the devops Player 2 wants to learn.

### D16. Recognizing returning players (later)
*Brief: 5.4 needs it, but accounts are a classic "no".*

- **A ★** No accounts. A nickname plus a random secret key, created on first launch and stored on your computer. The server saves each player's data under their key.
- **B** Log in with Discord.
- **C** Nickname only, so anyone can type any name.

**Why A:** you get persistence without building accounts. v0.1 can use C, since nothing is saved yet.

## Team and workflow

### D17. Who owns what
*Brief: 8.2 covers only physics/engine and networking/server.*

- **A ★**
  - **Player 1 (macOS), client and feel:** player movement and physics, how weapons feel, demon behavior and animation, the bursa map, visuals and psychedelic effects, HUD, audio.
  - **Player 2 (Windows), server and world:** networking, the dedicated server, game rules on the server (waves, spawning, damage, score), saving, builds, automated builds and deployment (CI/CD), and the main menu and connect screen.
  - **Shared:** story, NPCs, quests, balance.
- **B** Split by feature: each of you owns whole features end to end. For example, Player 1 owns weapons including their networking, and Player 2 owns demons including their AI and sync. Whoever owns that area of the code reviews.
- **C** Exactly as 8.2 says, with everything else decided per task.

**Why A:** every area gets an owner, so "the owner decides" (8.5) works, and Player 2 gets some gameplay too (waves, rules), not just plumbing. With an existing engine there's no engine to write, so Player 1's "engine" work becomes building the gameplay systems.

### D18. Tie-breaker for shared areas
*Brief: 8.5 only covers areas with an owner.*

- **A ★** Each of you writes your preference in the GitHub issue. If you still disagree after one discussion, pick the cheaper or more reversible option and log it in DESIGN.md.
- **B** Take turns breaking ties, and log each one.
- **C** Flip a coin.

**Why A:** it keeps disagreements short and leaves a record for future Claude Code sessions.

### D19. When you play together
*Brief: 8.1 gives hours but no shared time, and the definition of done needs the other person to play every change.*

- **A ★** One fixed weekly playtest on Discord, for example Sunday evening for 45 minutes, plus extra sessions when you're both online.
- **B** Asynchronous: the author of a change posts a short clip, and the reviewer plays it when free.
- **C** Two fixed sessions a week.

**Why A:** a fixed slot guarantees that "the other person played it". Each playtest also tests the game on the other person's operating system.

### D20. Git details
*Brief: 8.3 sets the rules but not the details.*

- **A ★**
  - Branch names like `name/<issue-number>-short-slug`.
  - Standard commit prefixes (Conventional Commits: `feat:`, `fix:`), and each pull request squashed into one commit.
  - A protected `main`: changes need a pull request, one approval and passing checks.
  - GitHub Actions automatically runs linting, format checks and tests, and builds the game.
  - Git LFS for large asset files: models, textures and audio.
  - A pull request template with a "how to test" section.
- **B** Minimal rules: free-form commits and merges, with no automated checks or LFS until v0.2.

**Why A:** automated checks are what keep "main always runs" and "no new warnings" true, and setting them up is part of Player 2's devops learning. Either way, the repo still needs a `main` branch, since today's default branch is `claude/game-design-prompt-template-cap3p9`.

### D21. One source of truth
*Brief: 8.4 says to update "this file", but step 2 creates DESIGN.md.*

- **A ★**
  - DESIGN.md is the living design, with a log of decisions.
  - GAME_DESIGN_PROMPT.md stays frozen as the original brief.
  - CLAUDE.md holds tech and conventions, ROADMAP.md holds the milestones, and GitHub issues hold the tasks.
- **B** Keep updating GAME_DESIGN_PROMPT.md as 8.4 says, with DESIGN.md copying it.

**Why A:** two design documents drift apart. One document per purpose keeps both players' Claude Code sessions in sync.

### D22. Hard "no" list
*Brief: 6.4 lists only monetization.*

- **A ★** Also rule these out for now:
  - accounts and logins
  - matchmaking or a server browser
  - mod support and anti-cheat
  - in-game voice chat, since you have Discord
  - randomly generated levels
  - writing your own engine or physics
  - realistic graphics
  - a Steam, console or mobile release
- **B** Keep only monetization and decide the rest case by case.

**Why A:** each item is a project of its own. Writing them down stops future sessions from drifting into them.

### D23. Language
*Brief: not covered.*

- **A ★** Code, comments, docs, commits and issues in English. In-game text in English with Polish flavor (signs, names, slang, food), kept in a translation file so a Polish version is cheap later.
- **B** English code, Polish in-game text.
- **C** Polish everywhere.

**Why A:** tools and Claude Code work best with English code and docs, and the translation file keeps a Polish version one step away.

## Questions only you can answer

- **Q1.** Player 2: what do you like doing together in games? 0.2 is blank. My guess from your other answers is fighting side by side against hordes and building defenses. Is that right?
- **Q2.** Which of you is `jlagun` on GitHub, and what is the other person's GitHub username? This is needed for the ownership section of CLAUDE.md and for assigning issues.
- **Q3.** Optional: can you share a sketch or photos of the real bursa layout (the ground floor, one dorm corridor, the courtyard)? The graybox map will follow it.
- **Q4.** Once you approve the roadmap, should Claude create the GitHub issues and milestones and assign them according to D17?
