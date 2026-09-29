# Bursa Tales: design review

> **Archived on 2026-09-29.** Step 1 is finished, and both players accepted every recommendation. The agreed design is now in [DESIGN.md](../DESIGN.md), and the milestones are in [ROADMAP.md](../ROADMAP.md). This file is kept as a record of the review. Don't edit it.
>
> Claude Code wrote this review from the original brief, [GAME_DESIGN_PROMPT.md](../GAME_DESIGN_PROMPT.md). Section numbers like 1.2 or 6.1 refer to that brief.

## The process

1. **Review the brief.** Summarize the game, list contradictions and gaps, answer Section 9, and propose 2–3 options with a recommendation for every blank or "suggest" field. ✅ Done: this file and [OPEN_DECISIONS.md](OPEN_DECISIONS.md).
2. **Write the agreed design.** Write `docs/DESIGN.md` and a `CLAUDE.md` with the tech stack, project structure, coding conventions and the git workflow from Section 8, so that every Claude Code session on either machine follows the same rules.
3. **Write `docs/ROADMAP.md`.** Break the v0.1 scope from Section 6 into small, ordered milestones, each one playable, and split the tasks between the two players according to Section 8.2. The first milestone is a "hello world": two clients connected to one world, seeing each other move.
4. **Only after the roadmap is approved,** scaffold the project and implement the first milestone. Keep it minimal, and make sure it runs on both machines (macOS and Windows).

**To resume** in a Claude Code session on either machine, first record your answers (see "How to answer" in [OPEN_DECISIONS.md](OPEN_DECISIONS.md)). Then ask Claude to continue with step 2 of `docs/DESIGN_REVIEW.md`.

## 1. The game in one paragraph

**Bursa Tales** is a co-op first-person shooter with survival, base-building and tower-defense elements. Up to 8 players share a persistent dedicated server that you run yourselves. A mysterious event has teleported your old high-school bursa on Okopowa Street in Warsaw into a psychedelic hell, and you play its former residents. You fight demons Doom-style with a growing arsenal of weird weapons. You gather resources, craft better gear, and fortify the bursa against demon attacks. You find your old dorm-mates, who are now NPCs giving quests, until you are strong enough to kill the boss and escape. The game should feel tense, psychedelic and creative. It should look low-poly and stylized (like Schedule I, not realistic), run on Windows and macOS, and leave voice chat to Discord. The first version (v0.1) is deliberately tiny: the bursa map, players, demons, weapons and shooting, all in multiplayer. Crafting, building, tower defense, NPCs, quests, story and skills come later.

## 2. Contradictions

1. The brief says "RTS" (1.2, 0.3), but also 3D first person (4.2). An RTS usually means a top-down commander view. → D2
2. 6.1 says "flat world … craft", but 6.2 says "bursa map" and 6.3 puts crafting in "later". → D6
3. The pitch says "co-op" (1.2), but 5.2 ticks "Both (teams, or opt-in PvP)". → D4
4. The brief wants a persistent world (5.4), roguelike elements (0.3), and an escape by killing the boss (1.2, 2.2). It never says what happens to the world after the boss. → D3
5. The core loop (3.1–3.3) and the first 5 minutes (3.4) are built entirely from "later" features: gathering, crafting, building, NPCs and quests. So v0.1 tests none of them. 3.1 also leaves out moving, aiming and shooting, which is all of v0.1. → D6
6. Art: Schedule I (clean low-poly) vs Doom and Boltgun (gritty retro) vs "psychedelic". 4.4 also says "if realistic", while 0.4 rules out realistic graphics. → D8
7. 8.4 says to keep "this file" (the brief) updated, but step 2 makes `docs/DESIGN.md` the agreed design. That would give you two sources of truth. → D21
8. 8.2 gives Player 1 the "game engine", but if you use an existing engine there is no engine to write. → D13, D17

## 3. Gaps

- **Blank or partial fields:** 0.2 is blank for Player 2. 0.3 has one line each instead of three, 0.5 has one combination instead of 2–3, and 1.4 has no "but Z". → Q1, D1
- **Missing from the "later" list:** these are mentioned in the brief but not listed in 6.3. DESIGN.md will keep them in a backlog.
  - automation, and NPCs that live on their own (2.1)
  - survival needs and the boss (2.2)
  - farming, loot boxes and grinding (0.3)
  - PvP (5.2) and persistence (5.4)
- **Never defined:**
  - which survival needs (D10)
  - what happens on death (D5)
  - what the world does while everyone is offline (D11)
  - how a persistent world recognizes returning players without accounts (D16)
  - the netcode model (D14)
  - where the server runs (D15)
- **Audio is never mentioned.** In a Doom-like game, sound carries half the tension. → D17
- **Unowned areas:** 8.2 leaves gameplay, AI, level design, art, audio, UI and story without an owner, so "the owner decides" (8.5) can't settle them. → D17, D18
- **No shared time:** 8.1 gives hours but no shared time slot. The definition of done (8.6) still needs the other person to play every change. → D19
- **Thin rules:** 6.4 lists only monetization. 8.3 has no branch naming, merge style, CI or plan for large asset files. → D22, D20
- **No `main` branch yet:** 8.3 assumes `main`, but the repository's default branch is currently `claude/game-design-prompt-template-cap3p9`. Step 2 should create `main` and make it the default branch in the GitHub settings.

## 4. Assumptions (until you say otherwise)

- **Controls:** keyboard and mouse only; gamepad later.
- **Art reference:** the style reference in 4.4 is the game Schedule I (the brief links to a Google Images search for it). "If realistic" is read as "realistically achievable", since 0.4 rules out realistic graphics.
- **Loot boxes:** they only use in-game currency. 6.4 already rules out real money, so they don't conflict with "no pay-to-win" (0.4).

## 5. What's realistic (answer to Section 9)

You have 2 × 8 hours a week, about 16 hours together, or 65–70 hours a month. First games usually take two to three times longer than planned. So every step below is small and ends with something you can play.

**Realistic:**

- **v0.1, about 6–8 weeks:**
  - 2–8 players on your own dedicated server
  - a graybox (rough, untextured blocks) of the bursa: ground floor, a corridor, the courtyard
  - two weapons against waves of one demon type
  - health, death, respawn and a wave counter

  "A few weekends" is the optimistic end.
- **About 6 months:**
  - a Call of Duty Zombies-style loop: demon currency and a mystery vending machine
  - barricades and turrets, a light version of tower defense
  - 4–6 weapons, 3–4 demon types and a first boss
  - the world saved on a rented server, with automatic builds
- **About 12 months:**
  - simple crafting, and free-placement base building that persists
  - a few NPC friends with simple quests
  - sanity with psychedelic effects
  - a second zone: the streets around the bursa, or the mall

**Not realistic for a first game:**

- Writing your own engine or physics.
- Factorio-style automation, RimWorld-style NPC lives, or real RTS unit control. Each is a whole game on its own.
- A detailed replica of Okopowa Street and Arkadia. Build a compressed, stylized version instead.
- Hundreds of demons at once over the network, like Brotato or Deep Rock Galactic: Survivor. Plan for 20–50.
- Competitive PvP that feels fair, anti-cheat, accounts, matchmaking, or a Steam release.
- Making all the 3D art and animation yourselves, or a story with cutscenes and voice acting.

**Biggest risks:**

- **Scope.** The brief touches about ten genres: survival, RTS, tower defense, crafting, farming, roguelike, loot boxes, MMO grinding, automation, colony sim, story and FPS. Add one new system per milestone, and only once the current build is fun.
- **Multiplayer cost.** Every feature costs more once it has to work over the network. Keeping players in sync, handling people who join late, and handling disconnects all add work. Building multiplayer in from day one, as you plan, is still cheaper than adding it later.
- **Motivation.** Projects on 8 hours a week die in long stretches with nothing playable. So every milestone ends with the two of you playing together.
- **Physics and networking overlap.** Player movement belongs to both of your areas. CLAUDE.md will define how the two sides connect.
