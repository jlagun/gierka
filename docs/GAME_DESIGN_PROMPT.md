# Game Design Prompt Template: Multiplayer Sandbox Game

**How to use this file**

1. Go through it together (a call works best). Every section has a few guiding questions and examples. The examples are there to spark ideas, not to pick from.
2. Write your answers in the `>` answer blocks. Short notes are fine. "Don't know yet" or "Claude, suggest 3 options" is also a valid answer.
3. Where you disagree, write both opinions down with your names. Claude can help you settle it.
4. When you're done, give the whole file to Claude Code with the prompt in the last section.

If you have no ideas at all, do **Section 0** first. It is a warm-up that produces raw material for everything else.

---

## Section 0: Warm-up (no ideas yet? start here)

Answer each one separately first, then compare.

**0.1 Three games you've both lost hours in, and the one moment in each you loved most.**
_Example: "Minecraft: the first night hiding in a dirt hut", "Terraria: finding a new biome", "Rust: a stranger betraying us"._
> Player 1:
>
> Player 2:

**0.2 What do you like doing *together* in games?** Building, exploring, fighting each other, fighting side by side, trading, pranking, surviving, racing?
> Player 1:
>
> Player 2:

**0.3 One sentence each: "It would be cool if there was a game where…"** Write three each, as silly as you like.
> Player 1:
>
> Player 2:

**0.4 Things you never want in this game.** _Example: grinding, pay-to-win vibes, realistic graphics we can't make, PvP griefing._
>

**0.5 Combine.** Pick the two most exciting lines from 0.3 and mash them together into one idea. Do this 2 or 3 times.
>

---

## Section 1: The pitch

**1.1 Working title** (can change later)
>

**1.2 One-sentence pitch.** Format: *"A [genre] where [who] [do what] in [where], and [the twist]."*
_Example: "A co-op sandbox where 2 to 4 players build a floating island that drifts through a storm, and everything you build changes how the island flies."_
>

**1.3 The feeling.** Three words for how playing should feel. _Examples: cozy, chaotic, tense, creative, silly, epic._
>

**1.4 Reference games.** "It's like X meets Y, but Z."
>

---

## Section 2: What "sandbox" means for us

"Sandbox" can mean very different things. Tick what fits and add notes.

**2.1 What can players change in the world?**
- [ ] Place and remove blocks/tiles (Minecraft, Terraria)
- [ ] Free placement of objects/props (Garry's Mod, Valheim building)
- [ ] Physics toys and contraptions (Besiege, Garry's Mod)
- [ ] Terrain sculpting (Astroneer)
- [ ] Logic/automation (redstone, Factorio belts)
- [ ] Creatures/NPCs that live on their own (Rimworld, Dwarf Fortress)
- [ ] Other:
>

**2.2 Is there a goal, or is it pure play?** Creative mode only, survival with needs, a light objective (boss, escape, deliver), or player-made goals?
>

**2.3 What stops the game from getting boring after 1 hour?** New materials to discover, danger, other players, progression, events?
>

---

## Section 3: Core loop

The core loop is what players repeat every few minutes. If it's fun, the game is fun.

**3.1 Moment to moment (seconds):** what are your hands doing? _Example: running, mining, placing, aiming._
>

**3.2 Short loop (minutes):** _Example: explore → gather → craft → build → defend at night → repeat._
>

**3.3 Long loop (hours / sessions):** what pulls you back next time? _Example: a bigger base, unlocking a new zone, a friend's creation to visit._
>

**3.4 The "first 5 minutes."** Describe what a new player sees and does after joining.
>

---

## Section 4: World and setting

**4.1 Setting and theme.** _Examples: fantasy, sci-fi, post-apocalypse, underwater, tiny people in a giant kitchen, abstract/no theme._
>

**4.2 Perspective.**
- [ ] 2D side view (Terraria)
- [ ] 2D top-down (Stardew, Rimworld)
- [ ] 3D first person
- [ ] 3D third person / isometric
>

**4.3 World shape and size.** Procedurally generated or handmade? Infinite, fixed size, a set of small islands, a single room?
>

**4.4 Art style we can realistically make.** _Examples: pixel art, voxels, low-poly, simple shapes with nice colors, free asset packs._
>

---

## Section 5: Multiplayer

**5.1 Players per world.** 2? Up to 8? Dozens?
>

**5.2 How do players relate?**
- [ ] Co-op only
- [ ] Competitive (PvP)
- [ ] Both (teams, or opt-in PvP)
- [ ] Mostly separate, visiting each other
>

**5.3 How do people connect?**
- [ ] One player hosts, friends join (easiest to start)
- [ ] Dedicated server we run
- [ ] Local network / same machine only (for the first version)
- [ ] Don't know, Claude please recommend
>

**5.4 Does the world persist when everyone logs off?** (Saved to a file? Keeps running on a server?)
>

**5.5 How do players communicate?** Text chat, emotes, pings, voice (probably use Discord), none.
>

**5.6 Where do we play from?** Desktop (which OS?), browser, mobile, console later?
>

---

## Section 6: Scope of the first playable version

Be ruthless. The first version should be playable by the two of you in a few weekends.

**6.1 The smallest thing that's already fun.** Only what's needed for the two of you to spend 15 minutes together in the same world and laugh.
_Example: "Two players join a flat world, can walk, place and break 3 block types, and see each other move."_
>

**6.2 Must have in v0.1** (max 5 bullet points)
>

**6.3 Later, not now** (dump every other idea here so it's not lost)
>

**6.4 Hard "no" for now** (things that will kill the project if we start them early: accounts, matchmaking, monetization, mod support…)
>

---

## Section 7: Tech preferences

Leave anything blank and Claude will propose options with pros and cons.

**7.1 Languages you know or want to learn.**
> Player 1:
>
> Player 2:

**7.2 Engine / framework.**
- [ ] Godot (free, GDScript or C#, good built-in networking)
- [ ] Unity (C#)
- [ ] Unreal (C++ / Blueprints, heavy)
- [ ] Bevy (Rust)
- [ ] Web: TypeScript + Phaser / Three.js + a Node server
- [ ] No preference, Claude please recommend based on the answers above
>

**7.3 Computers and OS each of you develops on.**
>

**7.4 Budget.** Free tools only? Willing to pay for a server or assets?
>

**7.5 Anything to avoid?** _Example: "no C++", "must run on an old laptop"._
>

---

## Section 8: How we work together

**8.1 Time.** Hours per week each, and when you're both online.
> Player 1:
>
> Player 2:

**8.2 Who owns what?** Split by area to avoid stepping on each other.
_Example split: Player 1 = networking + server, Player 2 = world, building and art. Or: take turns by feature._
>

**8.3 Git workflow.** _Suggested default: `main` always runs; each person works on their own branch per feature; small PRs; the other person reviews._
>

**8.4 How do both Claude Code sessions stay in sync?** _Suggested default: keep this file and a `CLAUDE.md` in the repo with decisions and conventions; update them whenever a decision changes; one GitHub issue per task, assigned to one person._
>

**8.5 How do we decide when we disagree?** _Example: the person who owns the area decides; or build both quickly and playtest._
>

**8.6 Definition of "done" for a task.** _Example: it runs, the other person played it once, no new warnings._
>

---

## Section 9: Open questions

Anything you're unsure about. Claude will answer these first.
>

---

## Section 10: Hand-off prompt for Claude Code

Once the sections above are filled in, paste this into Claude Code (from the repository root):

```
Read docs/GAME_DESIGN_PROMPT.md. It is the design brief my friend and I wrote
for a multiplayer sandbox game. Some answers are blank or say "suggest options".

1. First, summarize the game back to us in one paragraph, and list any
   contradictions or gaps in the brief. Answer the open questions in Section 9.
   For every blank or "suggest" field, propose 2-3 options with a recommendation.
   Stop and wait for our answers.
2. Then write docs/DESIGN.md (the agreed design) and a CLAUDE.md with the tech
   stack, project structure, coding conventions and the git workflow from
   Section 8, so every future Claude Code session on either of our machines
   follows the same rules.
3. Then write docs/ROADMAP.md: break the v0.1 scope from Section 6 into small,
   ordered milestones, each playable, and split tasks between us according
   to Section 8.2. Start with a "hello world": two clients connected to one
   world, seeing each other move.
4. Only after we approve the roadmap, scaffold the project and implement the
   first milestone. Keep it minimal and make sure it runs on both our machines.
```
