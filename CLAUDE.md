# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A procedural Pac-Man maze generator built in **GameMaker Studio 2024.14.0.207** using GML (GameMaker Language). There are no build commands, tests, or package managers — development is done entirely inside GameMaker Studio (open `MazeGenerator.yyp`, press F5 to run). Debug output (ASCII maze preview) prints to the GameMaker console on startup.

## Architecture

The system uses a two-stage pipeline: a **5×9 Cell Map** (high-level structure) is generated first, then converted into a **~34×31 Tile Map** (actual game grid). Only the left half is designed; it is mirrored to produce the symmetric final maze.

### Generation Pipeline

```
pacman_map_generate()                    ← entry point (pacman_maze.gml), retry loop
  pacman_map_reset()                     ← PACMAN_MAZE_RESET: init 5×9 cell grid, ghost area
  pacman_map_attempt_generate()          ← PACMAN_MAZE_GENERATION: fill cells, resize candidates
  pacman_map_is_desirable()              ← quality validation (corners, stacked pieces)
  pacman_map_setup_scale_coords()        ← PACMAN_MAZE_WALLS_TUNNELS: tile positions/sizes
  pacman_map_join_walls()                ← randomly add connecting edges (~25% chance)
  pacman_map_create_tunnels()            ← mark 1–2 tunnel exits on the right edge
  pacman_map_set_character_location()    ← character spawn positions
  pacman_map_get_tile_map()              ← PACMAN_MAZE_TILE_MAP: build final tile grid
```

Phase scripts: `PACMAN_MAZE_RESET`, `PACMAN_MAZE_GENERATION`, `PACMAN_MAZE_WALLS_TUNNELS`, `PACMAN_MAZE_TILE_MAP`. Wall sprite selection: `pacman_map_calculate_wall_tile()` in `scripts/PACMAN_MAP_WALL_TILE/PACMAN_MAP_WALL_TILE.gml`; sprite map JSON in `scripts/PACMAN_MAP_SPRITE_INDEX/PACMAN_MAP_SPRITE_INDEX.gml`.

### Key Data Structures

**`Cell`** (`scripts/Cell/Cell.gml`) — one node in the 5×9 grid. Tracks connections in 4 directions, group ID (for connected-component tracking), and flags for ghost space, tunnel candidates, and whether the cell is resized (tall = 4 tiles high, narrow = 2 tiles wide instead of the standard 3×3).

**`Tile`** (`scripts/Tile/Tile.gml`) — one node in the final tile grid. State is a `TileState` enum: `BLANK`, `PATH`, `PATHBLANK`, `WALL`, `GHOSTWALL`, `ENERGIZER`, `GHOSTSPACE`, `PATHTUNNEL`, plus spawn markers (`PACMAN`, `BLINKY`, etc.).

**`intTuple`** (`scripts/TupleFns/TupleFns.gml`) — lightweight (x, y, direction) struct used for coordinates throughout.

### Object Responsibilities

| Object | Role |
|---|---|
| `oMazeGenerator` | Calls `pacman_map_generate()` on Create; instantiates all game objects (dots, walls, ghosts, Pac-Man) from the tile map in Step |
| `oGhost` | Base ghost with full state machine (`GHOST_STATE`: CHASE, FRIGHTENED, EYES, IN_HOUSE, HOUSE_READY); child objects override spawn position and scatter corner |
| `oBlinky` | Extends `oGhost`; direct chaser (targets Pac's current tile) |
| `oPacman` | Player controller with buffered input and 16-state corner-turning system (`PAC_CORNER`) |

### Direction Conventions

Two separate direction systems are in use — be careful not to mix them:
- **`CellDirection`** (Cell/maze logic): `UP=0, RIGHT=1, DOWN=2, LEFT=3`
- **`GHOST_DIRECTION`** (ghost AI/movement): `RIGHT=0, UP=1, LEFT=2, DOWN=3`

Conversion helpers are in `scripts/GHOST_DIRECTION/GHOST_DIRECTION.gml` and `scripts/DirectionFns/DirectionFns.gml`.

### Ghost AI

`scripts/GHOST_CHASE/GHOST_CHASE.gml` is a thin entry point: it calls `ghost_chase_utils_no_up`, `ghost_chase_utils_forced_zones`, and `ghost_chase_pathfinding`. Pathfinding logic lives in `GHOST_CHASE_UTILS` (wall checks, NoUp/forced zones, data-driven priority table) and `GHOST_CHASE_PATHFINDING`. Grid-aligned turning at intersections is data-driven in `GHOST_GRID_TURN` (`ghost_apply_grid_turn`). Frightened-mode random direction: `random_direction` script. House behavior (bounce and exit) is in `GHOST_HOUSE` (`ghost_house_step`); speed selection (tunnel/chase/frightened/eyes, Elroy) is in `GHOST_SPEED` (`ghost_speed_step`). Both are called from `oGhost` Step_2. `scripts/GHOST_STATE/GHOST_STATE.gml` defines the state machine with a documented ASCII state diagram.

### Wall Sprite Selection

`pacman_map_calculate_wall_tile()` in `PACMAN_MAP_WALL_TILE.gml` determines the wall sprite index from cardinal and diagonal neighbors. Named constants and helpers (e.g. `pacman_map_wall_tile_state_is_path_adjacent`) are used for readability.

## Important Constants

Defined in `scripts/Map/Map.gml`:
- `CELL_MAP_SIZE_X = 5`, `CELL_MAP_SIZE_Y = 9`
- `TILE_SCALE = 3` (base cell-to-tile scale factor)

Ghost score multipliers on consecutive eats: 200 → 400 → 800 → 1600 (defined in `PACMAN_STATE`).

### Maze generation globals

Used by the pacman_maze pipeline (reset/generation/walls/tile_map scripts). Read/write as appropriate:
- `cellMap` — 2D array of Cell structures (5×9)
- `tileMap` — final 2D array of Tile structures (set by `pacman_map_get_tile_map`)
- `tallRows`, `narrowCols` — resize variation (one per column/row; -1 if none)
- `genCount` — number of generation attempts (in Map.gml init)
