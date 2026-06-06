# Beached Bounty: Design Document

## Core Concept

A pirate logistics-adventure game where the player scavenges valuable terrain
from a procedural ocean to trade for upgrades.

### Elevator Pitch

Beached Bounty is a cozy, pirate logistics-adventure game where the land itself
is your currency. Sail a vibrant, procedurally generated ocean to harvest
terrain and trade with unique NPCs. Use your earnings to master navigation and
upgrade your vessel, allowing you to venture deeper into the unknown to uncover
lost history and hidden treasure. The gameplay centers on a rewarding loop of
resource management, maritime navigation, and satisfying progression.

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

## (Example) Narrative

- **The Navigator’s Log:** A collectible, evolving notebook that automatically
  records findings. It acts as the primary vessel for storytelling, featuring
  "Field Notes" from a previous, mysterious explorer.
- **The Mystery:** Collect "Lost Charts" and "Recovered Pages" from NPCs and
  treasure chests. Completing the journal reveals the location of a final dock
  the ultimate narrative destination.
- **NPC Interaction:** Proximity triggers dialogue and shop access; NPCs provide
  dynamic reactions to market conditions and shop transactions.

## (Example) Art

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

## (Example) Audio

- **Ambience:** Emphasize the "cozy" atmosphere with environmental sounds such
  as gentle waves, wind, and distant seagulls.
- **Feedback Loops:** Create satisfying, distinct audio cues for mining and
  collecting blocks to provide tactile feedback.
- **Narrative Immersion:** Develop "signature sounds" for different chest
  rarities and rare discoveries to signal excitement without needing visual UI
  clutter.
- **Navigation:** Use subtle, rhythmic audio cues for the lighthouse beacons or
  incoming weather/current changes to assist player navigation at night.

## Technical Architecture

- **Perspective:** 3D Hexagonal Voxel.
- **Economy:** Dynamic pricing system that refreshes every 15 minutes (aligned
  with the Day/Night cycle). NPCs buy/sell blocks at different rates.
- **Serialization:** Save the player's progress, journal state, and world state.

## Pre-Existing and Temporary Assets

_We are starting with a significant foundation of pre-existing systems from
other projects, allowing us to pivot immediately to gameplay integration:_

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

# Beached Bounty: Development Roadmap

## Phase 1: The Core Loop (June 5 – June 8)

_Focus: Building a working vertical slice where all mechanics interact._

- **Technical Foundations:** Set up Hex-Voxel generation, prodecural ocean, and
  player character/boat movement physics.
- **The Loop:** Implement basic harvesting, cargo capacity management, and a
  single, functional dock island with a basic trade interface.
- **Narrative/Art:** Placeholder art for blocks and boat; establish the base
  "Explorer's Journal" UI shell.

## Phase 2: System Integration (June 9 – June 12)

_Focus: Implementing the "Game" systems that dictate player strategy._

- **Economy:** Build the 15-minute price fluctuation logic and the market
  refresh system.
- **Environment:** Integrate the Day/Night cycle and lighthouse beacon
  rendering.
- **Progression:** Finalize the "Navigator's Log" system (collecting/unlocking
  pages) and link it to NPC dialogue triggers.

## Phase 3: MVP & Content Expansion (June 13 – June 17)

_Focus: Horizontal expansion—adding the "meat" of the game._

- **Art/Audio Polish:** Replace placeholders with final hand-drawn textures,
  low-poly assets, and environmental soundscapes (waves, seagulls, UI feedback).
- **Horizontal Growth:** Implement multiple boat tiers, tool grades, and varied
  terrain block types.
- **Content:** Finalize NPC dialogue trees and treasure chest loot tables.

## Phase 4: Final Polish & Submission (June 18 – June 19)

_Focus: Bug fixing, balancing, and build verification._

- **Balancing:** Tune currency values and current strength to ensure the "cozy
  yet urgent" feel.
- **Final Verification:** UI/UX cleanup and ensuring all narrative pages are
  correctly hooked into the Journal.
- **Deadline:** Submission by 4:00 PM EST on June 19.

