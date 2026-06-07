# Beached Bounty: Design Document

**Table of Contents**

- [Identity](#identity)
    - [One-Liner](#one-liner)
    - [Elevator Pitch](#elevator-pitch)
- [Design Pillars](#design-pillars)
    - [Progression is a Performance, Not a Path](#progression-is-a-performance-not-a-path)
    - [Trust the Interface at Your Own Peril](#trust-the-interface-at-your-own-peril)
    - [The Sunk Cost is the Destination](#the-sunk-cost-is-the-destination)
- [Core Gameplay Loop](#core-gameplay-loop)
- [Features & System Architecture](#features--system-architecture)
    - [The Sand-Witch (Limitation)](#the-sand-witch-limitation)
    - [Faux-Store (Limitation)](#faux-store-limitation)
    - [Deceptive Navigator's Log](#deceptive-navigators-log)
    - [Hex-Voxel Logistics Loop](#hex-voxel-logistics-loop)
- [Design Recommendations](#design-recommendations)
- [Implementation Constraints](#implementation-constraints)
- [Example Design Directions](#example-design-directions)
    - [Narrative](#narrative)
    - [Art](#art)
    - [Audio](#audio)
- [Pre-Existing and Temporary Assets](#pre-existing-and-temporary-assets)
- [Development Roadmap](#development-roadmap)
- [Key Deliverables](#key-deliverables)
    - [Foundations](#foundations)
    - [Mechanics](#mechanics)
    - [Pivot](#pivot)
    - [Juice](#juice)
    - [Finalization](#finalization)

## Limitations: Instrictions are a Lie

The game says to do something. But you know better than to trust it. Mislead,
misdirect, and make players question everything. Just make sure the truth is
hidden somewhere... or not.

> **Optional:**
>
> - Add a sandwich (or maybe a sand-witch)
> - Faux in-app store

---

## Identity

### One-Liner

A pirate logistics-adventure game where the player scavenges valuable terrain
from a procedural ocean to trade for upgrades.

### Elevator Pitch

Beached Bounty is a cozy, pirate logistics-adventure game where the land itself
is your currency. Sail a vibrant, procedurally generated ocean to harvest
terrain and trade with unique NPCs. Use your earnings to master navigation and
upgrade your vessel, allowing you to venture deeper into the unknown to uncover
lost history and hidden treasure. The gameplay centers on a rewarding loop of
resource management, maritime navigation, and satisfying progression.

---

## Design Pillars

These pillars serve as the definitive criteria for all feature additions. If a
proposed mechanic or asset does not actively support these three pillars, it
will be excluded.

---

### Progression is a Performance, Not a Path

- **Definition:** The player’s advancement is a curated illusion of progress
  rather than a linear climb toward an ultimate goal.

- **Design Rule:** Every system (Upgrades, Journaling, Mapping) must suggest a
  trajectory of mastery that is intentionally circular or contradictory. The
  goal is to keep the player "busy" with logistics that provide the sensation of
  improvement while obscuring the reality that the destination is unreachable.

- **Why:** It creates a "Flow State" trap. By providing constant, incremental
  numerical feedback (e.g., higher hull strength, larger cargo capacity
  numbers), you trigger the player’s brain to recognize "leveling up." Because
  humans are hard-wired to enjoy patterns and growth, the player will
  voluntarily commit to the loop as long as the sensation of progress remains.
  They become addicted to the maintenance of their own illusion, never
  questioning the underlying math because they are too focused on the immediate,
  tangible act of optimizing their loadout.

---

### Trust the Interface at Your Own Peril

- **Definition:** The UI is an active participant in the deception.

- **Design Rule:** Instructions, tooltips, and market data must exist to lead
  the player astray. The interface serves to validate the player's biases,
  making them feel like they are "solving" the game while they are actually
  being led into inefficient loops.

- **Why:** It exploits Confirmation Bias. Players inherently treat the UI as the
  "Source of Truth." When a tooltip tells a player that a certain route is "High
  Yield," they aren't just reading data; they are receiving validation for their
  decision-making. If the player makes a bad trade, they will blame the
  randomness of the ocean or their own navigation skills rather than the
  interface itself. Because the UI uses professional design cues (parchment,
  ink, clean typography), it builds an subconscious authority that the player is
  hesitant to dismantle.

---

### The Sunk Cost is the Destination

- **Definition:** The player’s primary motivation is to prove their own
  competence in a system that refuses to reward it.

- **Design Rule:** Every piece of "lost history" or "ancient treasure"
  discovered must be fundamentally useless (e.g., a "Golden Compass" that only
  points to the player’s starting position), but lore-rich.

- **Why:** It facilitates Goal Substitution. When players realize (or suspect)
  that the extrinsic game loop—trading, upgrading, and making profit—is futile,
  they require a new reason to continue playing. By replacing functional rewards
  (a better boat) with narrative ones (a "Lost Chart" or a "Piece of Lore"), you
  shift the player's objective from "I need to win the game" to "I need to
  understand the mystery." Once a player has invested hours in finding "secret"
  fragments, they are locked in by the time they’ve already spent. They aren't
  playing to win anymore; they are playing to justify the effort they've already
  exerted.

---

## Core Gameplay Loop

1. **Harvest:** Collect terrain blocks from procedural islands using specific
   `Tool Strength`.
2. **Logistics:** Manage `Carry Capacity` while navigating ocean currents.
3. **Trade & Markets:** Sell cargo at island docks; prices fluctuate every day
   cycle to incentivize strategic trade routing.
4. **Upgrade:** Reinvest gold into better `Tools` and `Boats` to venture into
   deeper, more challenging zones.
5. **Navigate:** Utilize lighthouse beacons to locate docks during the dark
   night cycle.

---

## Features & System Architecture

---

### The Sand-Witch (Limitation)

- **Definition:** A rare, procedural spawn on sand blocks. Offers high-quality
  loot (but at a cost).

- **Sub-features:**
    - **The Menu:** A high-end, visual shop interface that displays rare
      upgrades (e.g., "Golden Hull") that provide higher stat numbers but
      hidden, negative modifiers (e.g., increased drag).

    - **Dialogue:** Cryptic hints that direct players to "secret" locations that
      are actually empty or trapped.

- **Pillar Links:**
    - **Trust the Interface at Your Own Peril:** The "high quality" stats entice
      the player into trading rare materials for items that actively hinder
      their performance.

- **Dependencies:**
    - NPC spawning logic
    - Dynamic Item/Shop UI.

---

### Faux-Store (Limitation)

- **Definition:** An overlay menu accessible at any dock, styled as a premium
  shop.

- **Sub-features:**
    - **Currency Sink:** Accepts gold for "Time Skips" or "Navigator’s Compass"
      items.

    - **The Lie:** Time skips do not actually advance world state to profitable
      windows; they trigger a 15-minute cooldown where the player earns zero
      gold.

- **Pillar Links:**
    - **Progression is a Performance, Not a Path:** It gives the player an
      active button to "optimize" their play, which actually results in an empty
      inventory.

- **Dependencies:**
    - Economy Manager
    - Timer System.

---

### Deceptive Navigator's Log

- **Definition:** The primary UI for progression tracking.

- **Sub-features:**
    - **False Objectives:** Auto-pins "Current Goals" that prioritize
      high-danger/low-reward routes.

    - **The Journal:** Automatically populates entries that occasionally
      contradict data seen in the shop (e.g., "This island is rich in Gold,"
      while the market interface shows zero demand for Gold).

- **Pillar Link:**
    - **Trust the Interface at Your Own Peril:** By having two in-game systems
      contradict each other, the player is forced to decide which lie to
      believe, preventing mastery.

- **Dependencies:**
    - Narrative Trigger Engine,
    - Journal UI.

---

### Hex-Voxel Logistics Loop

- **Definition:** The physical traversal and collection of terrain.

- **Sub-features:**
    - **Dynamic Currents:** Ocean physics push the boat, with UI arrows that
      oscillate between "Helpful" and "Hazardous" regardless of actual vector
      direction.

    - **Cargo Weight:** As players collect more, the boat sinks, changing the
      waterline physics.

- **Pillar Links:**
    - **Progression is a Performance, Not a Path:** Upgrading boat "Carry
      Capacity" feels like progress, but it also increases base weight and fuel
      consumption, nullifying the gain.

- **Dependencies:**
    - Physics/Buoyancy Controller
    - Procedural World Generator.

---

## Design Recommendations

- **The "Admiral" Scapegoat:** All UI errors and market failures must be
  filtered through the lens of "The Admiral’s Log." When the system
  intentionally misleads the player, the interface should display a note: “The
  currents were particularly fickle today; my charts must have been slightly
  off.” This offloads the frustration from the developer's code onto an in-game
  persona.

- **The Truth-Gating Protocol:** Implement a Perception variable hidden from the
  player.
    - **Early Game:** UI elements are consistent but false.

    - **Mid-Late Game:** As the player collects "Lost Charts," the Perception
      stat increases. This triggers minor "glitches" where the shop price
      occasionally aligns with the reality of the market, making the player feel
      they are "cracking the code" when they are actually just hitting the
      intended randomization curve.

- **Aesthetic Compensation:** The more detrimental an item’s stats, the higher
  the visual and audio polish applied to it. A "heavy/slow" hull upgrade must
  feature resonant, high-quality audio triggers and a visually impressive,
  ornate design to reward the player’s choice with spectacle rather than
  utility.

---

## Implementation Constraints

- **UI Inconsistency Protocol:** No UI element may reflect long-term trends. All
  dashboards, price trackers, and objective logs must exclusively display
  instantaneous, localized, or intentionally randomized data to ensure players
  cannot perform long-term "market analysis."

**Hard-Coded Market Randomization:** Price fluctuations must be hard-coded to
bypass player supply-and-demand inputs. Strategic trading must remain
mathematically impossible; all successful "trades" should appear as lucky
coincidences to the player.

**The "Safe Container" Mandate:** The game must maintain a "Cozy" aesthetic
(warm palettes, low-poly charm, soothing audio) to provide a psychological
buffer. This "safe container" is mandatory for the player's frustration to be
internalized rather than directed at the game’s hostility.

**Honeymoon Gating:** The "truth" of the game's deceptive nature must be
strictly gated. No systemic contradictions (e.g., Shop vs. Journal data) should
be discoverable within the first 15 minutes of gameplay.

**Performance Illusion:** The game must prioritize immediate feedback for all
player actions (mining, upgrading, sailing). The sensation of progress must be
prioritized over the reality of progression; every "level up" should involve a
distinct visual or sound effect to validate the player's perceived advancement.

**System Integrity:** All deceptive systems (Economy Manager, Narrative Trigger
Engine, Physics/Buoyancy) must be fully integrated into the Master Build by June
17 for stress testing and final verification of the "deception curve."

---

## Example Design Directions

These are just example directions for these design domains. This provides you
with some optional features, while leaving the design up to respective
departments.

---

### Narrative

- **The Navigator’s Log:** A collectible, evolving notebook that automatically
  records findings. It acts as the primary vessel for storytelling, featuring
  "Field Notes" from a previous, mysterious explorer.
- **The Mystery:** Collect "Lost Charts" and "Recovered Pages" from NPCs and
  treasure chests. Completing the journal reveals the location of an unreachable
  location.
- **NPC Interaction:** Proximity triggers dialogue and shop access; NPCs provide
  dynamic reactions to market conditions and shop transactions.

---

### Art

- **Visual Style:** 3D assets feature a clean, low-poly aesthetic to maintain
  performance and focus, while UI and textures evoke a hand-drawn field guide
  with ink washes and charcoal rubbings.
- **The Explorer’s Journal:** The core UI. Pages feature hand-drawn sketches of
  every item found. As the player collects "Lost Charts," these appear as
  pinned-in, rough-draft sketches that slowly reveal an ancient map.
- **Lighthouses:** Distinct, low-poly silhouettes combined with stylized,
  hand-drawn light beacons to ensure they are recognizable at night.
- **UI & Portraits:** Menus feature parchment textures, fountain-pen ink, and
  expressive, hand-drawn 2D character sketches for NPCs.
- **Visual Feedback:** Mining produces squish and squash effects akin a
  stylized, cartoony feel; water features stylized shader-based foam,
  reinforcing the idea of a living, breathing nautical map.

---

### Audio

- **Ambience:** Emphasize the "cozy" atmosphere with environmental sounds such
  as gentle waves, wind, and distant seagulls.
- **Feedback Loops:** Create satisfying, distinct audio cues for mining and
  collecting blocks to provide tactile feedback.
- **Narrative Immersion:** Develop "signature sounds" for different chest
  rarities and rare discoveries to signal excitement without needing visual UI
  clutter.
- **Navigation:** Use subtle, rhythmic audio cues for the lighthouse beacons or
  incoming weather/current changes to assist player navigation at night.

---

## Pre-Existing and Temporary Assets

We are starting with a significant foundation of pre-existing systems from other
projects, allowing us to pivot immediately to gameplay integration

- **World & Terrain:** Procedural hexagonal block generation with chunking;
  pre-existing hexagonal low-poly blocks.
- **Ocean & Physics:** Functional procedural water shader and buoyancy/boat
  movement systems.
- **Time & Environment:** Existing Day/Night cycle system.
- **Art Assets:** Ready-to-use library of low-poly pirate-themed and town
  assets.
- **Refinement Needed:** We will adapt existing procedural rules to scale based
  on distance from the hub, and modify the water shader to support variable
  intensity (calm vs. choppy waves).

---

## Development Roadmap

| Phase        | Dates             | Focus              |
| ------------ | ----------------- | ------------------ |
| Foundations  | June 7 - June 9   | Pipelines & Core   |
| Mechanics    | June 10 - June 12 | System Integration |
| Pivot        | June 13           | Feature Complete   |
| Juice        | June 14 - June 17 | Aesthetic Polish   |
| Finalization | June 18 - June 19 | Submission Prep    |

---

### Key Deliverables

- **Foundations:** Engine setup, hex-voxel generation, basic boat physics, and
  establishing the "Admiral's Log" asset workflow.

- **Mechanics:** Economy manager (hard-coded loops), NPC/Shop logic, and the
  "Perception" variable framework.

- **Pivot:** All deceptive systems (Faux-Store, Sand-Witch, UI contradictions)
  are integrated and functional.

- **Juice:** Finalizing the "Cozy" aesthetic, audio soundscapes, UI visual
  fidelity, and narrative "Admiral" flavor text.

- **Finalization:** Balancing the deception curve, stress testing, and final
  build verification for 4:00 PM submission.
