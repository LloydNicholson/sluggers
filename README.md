# sluggers

A construction-based 2D platformer originally built in GameMaker.  
The `copilot/rewrite-project-in-godot` branch contains a full rewrite of the
project in **Godot 4**.

---

## Original GameMaker project

The root of this repository contains the GameMaker project files (`.yyp`,
`objects/`, `scripts/`, `rooms/`, `sprites/`, etc.).  These remain as a
reference during the Godot rewrite.

---

## Godot rewrite (`godot/`)

All Godot 4 source lives in the [`godot/`](godot/) subdirectory.

### Project structure

```
godot/
├── project.godot               # Godot 4 project configuration
├── autoloads/
│   ├── GameState.gd            # Global singleton – timer, diamonds, creations, pause
│   └── InputManager.gd         # Runtime key-rebinding helper
├── scenes/
│   ├── player/
│   │   ├── Player.gd           # State-machine player (GROUND / AIR / WALL)
│   │   └── Player.tscn
│   ├── objects/
│   │   ├── Solid.tscn          # Static terrain block
│   │   ├── SolidCreation.*     # Player-placed solid block (Z key)
│   │   ├── BouncyCreation.*    # Player-placed bouncy block (X key)
│   │   ├── Diamond.*           # Collectible gem
│   │   ├── MovingBlock.*       # Horizontally-shuttling platform
│   │   ├── Enemy.*             # Hazard that restarts the level on contact
│   │   ├── DeathArea.*         # Kill-zone (pits, spikes)
│   │   └── RoomWarp.*          # Teleport trigger between rooms
│   ├── ui/
│   │   ├── HUD.*               # Timer / diamond / creations display
│   │   └── PauseMenu.*         # Multi-page pause menu (audio/difficulty/graphics/controls)
│   ├── camera/
│   │   └── GameCamera.*        # Lerp-follow camera
│   └── rooms/
│       ├── Room0.tscn          # Level 1
│       └── Room1.tscn          # Level 2
└── assets/
    └── README.md               # Sprite / audio asset list (to be imported)
```

### How to open

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open Godot → **Import** → select `godot/project.godot`
3. Press **F5** to run from Room 0

### Default controls

| Action              | Key          |
|---------------------|--------------|
| Move left           | ← Left arrow |
| Move right          | → Right arrow |
| Jump                | ↑ Up arrow   |
| Place solid block   | Z            |
| Place bouncy block  | X            |
| Pause               | Escape       |
| Restart level       | R            |

Controls can be rebound from the **Pause → Settings → Controls** menu.

### Game mechanics

| Mechanic | Description |
|---|---|
| Ground / Air / Wall states | Full state-machine movement with friction, variable jump height, wall-slide, and wall-jump |
| Block creation | Limited budget of placeable blocks per level (solid or bouncy) |
| Diamonds | Collectibles that accumulate across the run |
| Moving platforms | Horizontal platforms that carry the player |
| Room warps | Teleporters that transition between levels |
| Pause menu | Audio, difficulty, graphics, and rebindable-controls settings |