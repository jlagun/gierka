# Bursa Tales: game design

> **Status:** agreed by jlagun (Player 1) and bionosal (Player 2) on 2026-09-29.
>
> This is the living design. When a decision changes, update this file in the same pull request and add a line to the [decision log](#14-decision-log). Section 13 lists a few details this document fills in. They stand unless one of you objects.
>
> Related documents:
> - [CLAUDE.md](../CLAUDE.md): tech stack, project structure, conventions and git workflow
> - [ROADMAP.md](ROADMAP.md): milestones and who does what
> - GitHub issues: one per task
> - [GAME_DESIGN_PROMPT.md](GAME_DESIGN_PROMPT.md): the original brief, frozen
> - [archive/](archive/): the step-1 review and the options we considered

## 1. Pitch

**Rust meets Doom, but you defend your Polish high-school dorm in hell, and your old roommates give the quests.**

Bursa Tales is a co-op first-person shooter with survival, base-building and tower-defense elements. Up to 8 players share one server. A mysterious event has teleported the bursa on Okopowa Street in Warsaw into a psychedelic hell. The bursa is a boarding house for high-school students, and the two of you lived there. The players are its former residents.

Players fight demons with a growing arsenal of weird weapons and fortify the bursa against attacks. Later they also gather resources, craft gear, and find their old dorm-mates, who are now NPCs giving quests. The goal is to get strong enough to kill the boss and escape.

## 2. Pillars

Every feature should serve at least one of these. A feature that serves none of them waits.

1. **Fight side by side.** Teamwork against demon hordes is the heart of the game. It's what both of you like most about playing together.
2. **Tense and weird.** Fast, tense combat in a psychedelic hell.
3. **Silly in the details.** Dorm humor, Polish flavor and pranks. The fun is in the details, not in turning the game into a comedy.
4. **Our bursa.** The real building and the people from it, turned into a playground.
5. **Get stronger.** Better weapons first. Later, exploring the world, gathering, crafting and a bigger base.

## 3. Setting

- **The bursa** is a real building on Okopowa Street, near the Arkadia mall. The game uses a stylized, compressed version, not a replica (see section 8).
- **The world outside** is hell: post-apocalyptic, abstract, "Warsaw, but in hell". The world is handmade and finite.
  - The first zone is the bursa and its yard.
  - Later zones are the upper floor, the streets around the bursa, and then the mall.
- **The characters** are the players, who were residents of the bursa. Their old dorm-mates appear later as NPCs who give quests. The repository is public, so use their first names or nicknames, and ask them first.
- **The ending** is killing the boss, which lets the players escape hell and ends the semester (see section 5).

## 4. Look, sound and tone

- **Art:** low-poly and stylized, like Schedule I. No realistic graphics.
  - Models come from free CC0 asset packs: Kenney, Quaternius and Poly Pizza. Animations come from Mixamo.
  - The hell look comes from a color palette and a psychedelic post-processing shader.
  - A retro pixel filter, in the style of Boltgun, can be tried later on top.
- **Tone:** like Doom. Combat is tense and fast, and the world is weird. The humor lives in the details: dorm signs, your NPC friends, and Polish food as power-ups.
- **Sound:** CC0 sound effects and music. Sound carries half the tension, so it is part of every combat feature, not an afterthought. Voice chat stays on Discord.
- **Language:** code and docs are in English.
  - In-game text is in English with Polish flavor: names, signs, slang and food.
  - Player-facing text goes through a translation table, so a Polish version stays cheap to add.

## 5. How the game is structured

- **Semesters:** the world persists between sessions until the players kill the boss and escape. Then a new semester starts in a fresh, harder hell, and a little progress carries over (rescued friends, cosmetics). Persistence arrives after v0.1.
- **While nobody is online,** the world pauses: the server saves and idles, and nothing attacks an empty base.
- **Players:** up to 8 per world, co-op only.
  - Friendly fire is a server setting, off by default.
  - Opt-in PvP, such as duels in the bursa gym, may come later.
- **Death:** you respawn at the bursa after about 5 seconds and keep everything. Later, you'll drop your demon currency where you died and have to run back for it.
- **Returning players** get no accounts. Once saving exists, the game creates a nickname plus a random secret key on first launch, stored on your computer. The server saves player data under that key. v0.1 uses the nickname only.

## 6. Core loops

- **Moment to moment:** move, aim, shoot, dodge, pick things up.
- **The v0.1 loop:**
  1. Join the server.
  2. Grab a weapon.
  3. Survive growing waves of demons.
  4. Die and respawn.
  5. Try to beat your best wave.
- **The target short loop, after v0.1:** explore → gather → craft → build → defend → repeat.
- **The long loop:** better gear and a bigger base across sessions. Beating the boss ends the semester.

## 7. v0.1: wave survival in the bursa

v0.1 is the smallest version that two players can enjoy together for 15 minutes.

**The first 5 minutes:**

1. Start the game, and type the server address and a nickname.
2. Spawn in the entrance hall, next to the portier's desk, holding a pistol.
3. The shotgun lies in the mentor room, confiscated by the mentor. Whoever wants it has to go and get it.
4. A portal opens in the yard. The first wave breaks in through the cantine windows and the main entrance.
5. The waves keep growing. The run ends when all players are dead at the same moment. The game then shows the wave you reached and your best wave, and a new run starts from wave 1.

**Contents:**

| Area | v0.1 content |
|---|---|
| Map | A graybox (untextured blocks) of the bursa ground floor plus the yard. The stairs to the upper floor are blocked. |
| Players | First person, keyboard and mouse (gamepad later), health, a nickname above your head, respawn after about 5 seconds. |
| Weapons | Pistol and shotgun. Both are "hitscan": the shot hits instantly, with no bullet flying through the air. Weapons are defined as data, so a new weapon is mostly new numbers. |
| Demons | One melee type in two variants: fast and weak, slow and tanky. Also defined as data. |
| Waves | One portal. Each wave has more and tougher demons, with a short break between waves. |
| HUD | Health, ammo, crosshair, hit marker, wave number, best wave. |
| Multiplayer | 2–8 players on a dedicated server that runs without a window. Friendly fire off. |
| Not in v0.1 | Saving, currency, building, crafting, NPCs, the upper floor, projectile weapons and ranged demons. |

## 8. The map: the bursa

The reference is [reference/bursa-ground-floor.png](reference/bursa-ground-floor.png), from jlagun (2026-09-29). It shows the ground floor. You called it "floor 1", and the upper floor "floor 2".

**The ground floor, as in the reference:**

- **Shape:** the building is shaped like a "7". One wide wing runs along the street at the top of the picture. A long wing runs down the right side. The open area inside the bend, at the bottom left of the picture, is the yard.
- **Entrance:** in the middle of the street side. The portier's lodge is just inside, on the right.
- **Towards the cantine:** a corridor runs left from the entrance to the cantine. The cantine is a large room that fills the left end of the street wing.
- **The long wing:** a second corridor runs down it.
  - On its right side are 4 residents' rooms.
  - On its left side are the mentor room (the room of the tutor on duty) in the middle, then the stairs to the upper floor, and finally the bathroom at the far end.
- **Unknown:** the area in the middle of the ground floor isn't labeled in the reference (open question in section 13).
- **The upper floor** has more residents' rooms. Its layout isn't drawn yet, and it comes in a later version.

**Added for the game (not part of the real building):**

- The demon portal in the yard.
- Demons get in through broken cantine windows facing the yard, and through the main entrance.
- Proportions are compressed where that makes the game play better. jlagun owns the map and decides the exact layout.

## 9. Multiplayer and technology, in short

The details are in [CLAUDE.md](../CLAUDE.md).

- **Engine:** Godot 4.7, with statically typed GDScript.
- **Server:** a dedicated server, built from the same project and run without a window.
  - During development it runs on one of your laptops, and you connect over the internet with Tailscale.
  - After v0.1 it moves to a rented Linux server (a VPS) with Docker, for about €4–6 a month.
- **Who controls what over the network:**
  - Each game client moves its own player.
  - The server owns demons, health, damage, waves and score.
  - The shooter's client reports hits, and the server checks them and applies the damage.
  - Full server control with lag compensation ("netcode 2.0") is an optional later milestone.
- **Platforms:** Windows and macOS for playing, Linux for the server.

## 10. Later systems (provisional)

These are recorded so no idea is lost. Each one gets designed properly when its milestone comes.

- **Building and tower defense:** you build in first person, placing barricades, turrets and traps freely. There is no commanding of units. A top-down planning map is an optional extra.
- **Economy and loot:** demons drop currency. A mystery vending machine in the bursa sells random weapons and upgrades. It uses in-game currency only, never real money. Drops with rarity tiers come once there are enough weapons.
- **Survival needs:** sanity comes first.
  - It drops in darkness and near demons, and recovers in the bursa.
  - Low sanity brings psychedelic effects and fake demons.
  - Hunger comes only if it adds fun.
- **Gathering, crafting and farming.**
- **NPC friends, quests and the story.**
- **Character skills, and grinding for loot.**
- **The boss, semesters and saving.**
- **Opt-in PvP.**
- **Automation and NPCs that live on their own:** small forms only, such as a switch that powers turrets. No Factorio-style logistics and no RimWorld-style NPC lives.
- **More zones:** the upper floor, the streets around the bursa, and the mall.

## 11. Hard "no" for now

- monetization of any kind
- accounts and logins
- matchmaking or a server browser
- mod support
- anti-cheat
- in-game voice chat (you use Discord)
- randomly generated levels
- writing your own engine or physics
- realistic graphics
- a Steam, console or mobile release

## 12. Team

The details are in [CLAUDE.md](../CLAUDE.md).

- **jlagun** (Player 1, macOS) owns client and feel: movement, weapons, demon behavior, the map, visuals, HUD and audio.
- **bionosal** (Player 2, Windows) owns server and world: networking, the dedicated server, game rules on the server, saving, builds, CI/CD and deployment, and the main menu.
- **Shared:** story, NPCs, quests, balance and art direction.
- **Deciding:**
  - The owner of an area decides.
  - In shared areas, each of you writes a preference in the GitHub issue. If you still disagree after one discussion, pick the cheaper or more reversible option and log it here.
- **Playtests:** one fixed weekly playtest on Discord, plus extra sessions when you're both online. The day and time are still open (see section 13).

## 13. Details filled in by this document, and open questions

These details weren't in the brief or the decisions, so this document fills them in. They stand unless one of you says no:

- Players spawn in the entrance hall, next to the portier's desk.
- Everyone starts with a pistol. The shotgun lies in the mentor room.
- A run ends when all players are dead at the same moment. The score is the wave you reached, and the best wave is remembered while the server runs.
- The demon portal is in the yard. Demons break in through the cantine windows and the main entrance.
- The upper floor is closed in v0.1.

Open questions:

- What was in the middle of the ground floor? It's unlabeled in the reference. If it was a common room (świetlica), players should spawn there instead.
- What does the upper floor look like? A sketch is enough, and only when you get to that zone.
- What day and time is the weekly playtest?

## 14. Decision log

D1–D23 were made on 2026-09-29 by both players, and the options you considered are in [archive/OPEN_DECISIONS.md](archive/OPEN_DECISIONS.md). Later decisions say who made them and when. Add new decisions at the bottom as D27, D28, and so on.

| # | Decision | Choice |
|---|---|---|
| D1 | One-line pitch | "Rust meets Doom, but you defend your Polish high-school dorm in hell, and your old roommates give the quests." |
| D2 | What "RTS" means | You build and defend in first person, placing defenses yourself. No commanding of units. |
| D3 | After the boss | Semesters: the world persists until you kill the boss, then a new, harder semester starts. |
| D4 | Co-op or PvP | Co-op. Friendly fire is a server setting, off by default. Opt-in PvP comes later. |
| D5 | Death | Respawn at the bursa after about 5 seconds and keep everything. Later, you drop your currency. |
| D6 | What v0.1 is | Wave survival in the bursa, like Call of Duty Zombies. |
| D7 | How big v0.1 is | Graybox ground floor and yard, pistol and shotgun, one demon type in two variants, one portal, HUD. |
| D8 | Art style | Low-poly and stylized (Schedule I), from CC0 packs, with a hell palette and a psychedelic shader. |
| D9 | Tone | Doom's tone, with the humor in the details. |
| D10 | Survival needs (later) | Sanity first. Hunger only if it adds fun. |
| D11 | The world while offline (later) | It pauses. |
| D12 | Loot (later) | A mystery vending machine first, rarity drops later. In-game currency only. |
| D13 | Engine and language | Godot 4 with statically typed GDScript. The version is pinned in CLAUDE.md. |
| D14 | Network model | Each client moves its own player. The server owns demons, health, damage, waves and score, and checks the hits that clients report. |
| D15 | Where the server runs | On a laptop over Tailscale during development, then a Linux VPS with Docker after v0.1. |
| D16 | Returning players (later) | A nickname plus a secret key stored on your computer. No accounts. |
| D17 | Ownership | jlagun owns client and feel. bionosal owns server and world. Story, NPCs, quests and balance are shared. |
| D18 | Tie-breaker | Write your preferences in the issue, discuss once, then pick the cheaper or more reversible option and log it here. |
| D19 | Playtests | A fixed weekly Discord playtest, plus extra sessions. |
| D20 | Git details | Branch per issue, Conventional Commits, squash merges, protected `main`, CI, Git LFS, a PR template. |
| D21 | Source of truth | DESIGN.md is the design, CLAUDE.md the conventions, ROADMAP.md the milestones, issues the tasks. The brief is frozen. |
| D22 | Hard "no" list | See section 11. |
| D23 | Language | English code and docs. English in-game text with Polish flavor, through a translation table. |
| D24 | Ammo | Weapons have magazines, which reload with R or by themselves when empty. Spare ammo is unlimited, so v0.1 has no ammo pickups. (jlagun, 2026-10-01, in M1.2) |
| D26 | Sprint | Hold Shift to sprint. It only works while moving forward, so backing away from demons while shooting them happens at walking speed. There is no stamina, and you can shoot while sprinting. (jlagun, 2026-10-02, in M1.1) |
