# Pacman Maze Generation - Developer's Guide

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Data Structures](#data-structures)
4. [Generation Pipeline](#generation-pipeline)
5. [Core Algorithms](#core-algorithms)
6. [Pacman Compliance Features](#pacman-compliance-features)
7. [Code Walkthrough](#code-walkthrough)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This system generates procedurally-created Pacman-compliant mazes using a two-stage approach:
1. **Cell Map Generation**: Creates a 5×9 grid of cells representing high-level maze structure
2. **Tile Map Conversion**: Converts cells into a detailed tile map with walls, paths, and game elements

The generated maze maintains classic Pacman characteristics:
- **Symmetrical design** (left-right mirroring)
- **Side tunnels** for wraparound navigation
- **Ghost spawn area** in the top-left corner
- **Energizers** (power pellets) in strategic locations
- **Proper wall connectivity** for visual consistency

---

## Architecture

### System Dimensions

- **Cell Map**: 5 columns × 9 rows (`CELL_MAP_SIZE_X = 5`, `CELL_MAP_SIZE_Y = 9`)
- **Tile Map**: Approximately 34 columns × 31 rows (calculated from cell map)
- **Cell-to-Tile Scale**: Each cell typically represents 3×3 tiles, with variations

### Generation Flow

```
pacman_map_generate()
    ├─> pacman_map_reset()              [Initialize cell map]
    ├─> pacman_map_attempt_generate()    [Create maze structure]
    ├─> pacman_map_is_desirable()       [Quality validation]
    ├─> pacman_map_setup_scale_coords() [Cell → Tile coordinates]
    ├─> pacman_map_join_walls()         [Improve wall structure]
    └─> pacman_map_create_tunnels()     [Add side tunnels]
        └─> pacman_map_get_tile_map()   [Final tile map generation]
```

---

## Data Structures

### Cell Structure (`Cell_create`)

A cell represents a region of the maze that can contain multiple tiles.

```gml
Cell {
    position: intTuple          // (x, y) in cell map [0-4, 0-8]
    filled: bool               // Whether cell is part of maze
    number: int                // Order in which cell was filled
    group: int                 // Connected component ID
    
    connections: bool[4]       // [UP, RIGHT, DOWN, LEFT] connection flags
    next: Cell[4]              // Neighbor cell references
    
    // Special flags
    isGhostSpace: bool         // Part of ghost spawn area
    isRaiseHeightCandidate: bool
    raiseHeight: bool          // Cell is 4 tiles tall instead of 3
    isShrinkWidthCandidate: bool
    shrinkWidth: bool          // Cell is 2 tiles wide instead of 3
    
    // Tunnel candidates
    isEdgeTunnelCandidate: bool
    isVoidTunnelCandidate: bool
    isSingleDeadEndCandidate: bool
    singleDeadEndDir: int      // Direction of dead end
    isDoubleDeadEndCandidate: bool
    topTunnel: bool            // Cell contains tunnel exit
    
    // Calculated during conversion
    tilePosition: intTuple      // Top-left tile position
    tileSize: intTuple          // Width × height in tiles
}
```

### Tile Structure (`Tile_create`)

A tile represents a single game tile (wall, path, pellet, etc.).

```gml
Tile {
    position: intTuple          // (x, y) in tile map
    state: TileState            // Current tile type
    cell: Cell                  // Reference to parent cell
}
```

### TileState Enum

```gml
enum TileState {
    BLANK = 0          // Empty/void space (not walkable)
    PATH = 1           // Walkable path with pellet
    PATHBLANK = 2      // Walkable path without pellet (tunnel)
    WALL = 3           // Solid wall
    GHOSTWALL = 4      // Wall ghosts can pass through
    ENERGIZER = 5      // Power pellet location
    GHOSTSPACE = 6     // Ghost spawn/home area
}
```

### CellDirection Enum

```gml
enum CellDirection {
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3
}
```

---

## Generation Pipeline

### Phase 1: Initialization (`pacman_map_reset`)

**Purpose**: Create a fresh cell map and establish neighbor relationships.

**Process**:
1. Reset the filled cell counter
2. Create a 5×9 array of empty cells
3. Link each cell to its four neighbors (UP, RIGHT, DOWN, LEFT)
4. Pre-configure the ghost space area (cells at [0,3], [1,3], [0,4], [1,4])
5. Initialize `tallRows` and `narrowCols` arrays for variation tracking

**Ghost Space Setup**:
- Cells [0,3] and [1,3]: Connected LEFT, RIGHT, DOWN
- Cells [0,4] and [1,4]: Connected LEFT, RIGHT, UP
- All marked as `filled` and `isGhostSpace = true`

---

### Phase 2: Maze Structure Generation (`pacman_map_attempt_generate`)

**Purpose**: Build the core maze structure by filling cells from left to right.

#### Algorithm Overview

The generation uses a **left-to-right filling strategy** with probabilistic growth:

1. **Find leftmost empty cells**: Get all unfilled cells in the leftmost column with empty cells
2. **Select random starting cell**: Choose one cell from the leftmost empty set
3. **Grow a "piece"**: Extend the cell horizontally/vertically to form connected groups
4. **Repeat** until all cells are filled

#### Piece Growth Logic

Each piece starts as a single cell and can grow up to size 5:

```gml
probStopGrowingAtSize = [0.0, 0.0, 0.1, 0.5, 0.75, 1.0]
```

- **Size 1**: Always continues (0% stop chance)
- **Size 2**: 10% chance to stop
- **Size 3**: 50% chance to stop
- **Size 4**: 75% chance to stop
- **Size 5**: Always stops (100% chance)

#### Special Cases

**Top/Bottom Row Single Cells** (35% probability):
- If starting at top or bottom row, may create a single-cell piece
- Connects upward (top row) or downward (bottom row)
- Limited to one per row to prevent excessive fragmentation

**Size 2 Extension**:
- When a piece reaches size 2, checks if it can extend further
- Looks ahead 2 cells to the right
- If open, extends upward or downward (50% each if both available)
- Limited by `MAX_LONG_PIECES = 1` per generation

**Right Edge Handling**:
- Cells at `x == CELL_MAP_SIZE_X - 1` automatically connect RIGHT
- Marked as `isRaiseHeightCandidate` for potential height variation

**Size 3/4 Extension**:
- After stopping at size 3 or 4, may extend one more cell
- 50% probability (`probExtendAtSize3or4`)
- Limited by `MAX_LONG_PIECES`

#### Group Assignment

Each piece gets a unique `group` ID. Cells in the same piece share the same group, allowing the system to:
- Track connected components
- Merge groups when tunnels connect them
- Ensure proper path generation

---

### Phase 3: Quality Validation (`pacman_map_is_desirable`)

**Purpose**: Ensure the generated maze meets Pacman design requirements.

#### Validation Checks

1. **Corner Constraints**:
   - Top-right corner `[4,0]`: Must NOT connect UP or RIGHT
   - Bottom-right corner `[4,8]`: Must NOT connect DOWN or RIGHT
   - Ensures proper corner wall structure

2. **Stacked Pieces Detection**:
   - Checks for 2×2 blocks of cells forming "stacked" patterns
   - If found at left edge (`x == 0`), rejects maze
   - Otherwise, joins the stacked pieces into a single group

3. **Tall Row Selection** (`pacman_map_choose_tall_rows`):
   - Must select at least one column to have a "tall row" (4 tiles high)
   - Checks columns 0-2 for valid candidates
   - Uses recursive validation to ensure valid height chains

4. **Narrow Column Selection** (`pacman_map_choose_narrow_cols`):
   - Must select at least one row to have a "narrow column" (2 tiles wide)
   - Checks columns from right to left
   - Uses recursive validation to ensure valid width chains

**If any validation fails**: Generation restarts from Phase 1.

---

### Phase 4: Coordinate Scaling (`pacman_map_setup_scale_coords`)

**Purpose**: Convert cell coordinates to tile coordinates, accounting for size variations.

#### Base Conversion

- **X coordinate**: `tileX = cellX * 3`
- **Y coordinate**: `tileY = cellY * 3`

#### Narrow Column Adjustment

If a cell's row has a narrow column at a position less than the cell's X:
```gml
tileX = tileX - 1  // Shift left by 1 tile
```

#### Tall Row Adjustment

If a cell's column has a tall row at a position less than the cell's Y:
```gml
tileY = tileY + 1  // Shift down by 1 tile
```

#### Size Assignment

- **Width**: `3` (normal) or `2` (if `shrinkWidth`)
- **Height**: `3` (normal) or `4` (if `raiseHeight`)

---

### Phase 5: Wall Joining (`pacman_map_join_walls`)

**Purpose**: Improve visual consistency by connecting isolated wall segments.

#### Top Row Joining

For cells in the top row (`y == 0`):
- If cell has no LEFT/RIGHT/UP connections and no DOWN connection (or cell below has no DOWN)
- And neighbors don't connect UP
- And not blocking a horizontal path below
- **25% chance** to connect UP (creating a wall cap)

#### Bottom Row Joining

Similar logic for bottom row (`y == CELL_MAP_SIZE_Y - 1`):
- **25% chance** to connect DOWN

#### Right Column Joining

For cells in the right column (`x == CELL_MAP_SIZE_X - 1`):
- If cell connects LEFT but not UP/DOWN/RIGHT
- And cell to left has no UP/DOWN/LEFT connections
- **50% chance** to connect RIGHT (extending wall to edge)

---

### Phase 6: Tunnel Creation (`pacman_map_create_tunnels`)

**Purpose**: Add side tunnels for wraparound navigation (classic Pacman feature).

#### Tunnel Candidate Classification

The system analyzes cells in the rightmost column (`x == CELL_MAP_SIZE_X - 1`):

1. **Edge Tunnel Candidates**:
   - Cells at `y` positions 2-6 (middle rows)
   - No UP connection
   - Used when other options unavailable

2. **Void Tunnel Candidates**:
   - Cell connects RIGHT
   - Cell above OR below has RIGHT connection (creating a "void")
   - Preferred for single tunnel generation

3. **Single Dead End Candidates**:
   - Cell does NOT connect RIGHT
   - Cell does NOT connect DOWN
   - Exactly one of UP/DOWN neighbors has RIGHT connection
   - Creates tunnel by connecting RIGHT and marking appropriate cell

4. **Double Dead End Candidates**:
   - Cell does NOT connect RIGHT
   - Both UP and DOWN neighbors have RIGHT connections
   - Cell to left connects both UP and DOWN
   - Creates a double tunnel (top and bottom)

#### Tunnel Selection Logic

**Number of Tunnels**: Random choice
- **1 tunnel**: 55% probability
- **2 tunnels**: 45% probability

**Single Tunnel Priority**:
1. Void tunnel (if available)
2. Single dead end (if available)
3. Edge tunnel (if available)
4. **Reject maze** if none available

**Double Tunnel Priority**:
1. Double dead end (if available) - creates both tunnels at once
2. Otherwise: Top tunnel from top candidates, Bottom tunnel from bottom candidates
3. **Reject maze** if can't create both

#### Tunnel Validation

After tunnel creation, checks for **exit condition**:
- If a tunnel creates a clear horizontal path from right edge to left edge at the same Y level, the maze is rejected
- Prevents trivial mazes with straight horizontal tunnels

#### Void Tunnel Connection

For void tunnel candidates NOT selected as main tunnels:
- Automatically connects UP to merge the void space
- Merges groups to maintain connectivity

---

### Phase 7: Tile Map Generation (`pacman_map_get_tile_map`)

**Purpose**: Convert the cell map into a detailed tile map with all game elements.

#### Tile Map Dimensions

```gml
subWidth = CELL_MAP_SIZE_X * 3 - 1 + 2  // = 16
subHeight = CELL_MAP_SIZE_Y * 3 + 1 + 3  // = 31
fullWidth = (subWidth - 2) * 2            // = 28 (symmetrical)
```

The map is **symmetrical**: left half mirrors right half.

#### Step 1: Initialize Tile Map

Create a 2D array of tiles, all initially `BLANK`.

#### Step 2: Populate from Cell Map

For each cell:
- Mark all tiles within `tileSize` as belonging to that cell
- If cell is ghost space, mark tiles as `GHOSTSPACE`

#### Step 3: Generate Paths

Paths are created based on:
- **Group boundaries**: Tiles between different groups become paths
- **Cell connections**: If cell doesn't connect UP, create path above
- **Adjacent paths**: If neighbor has path and cell doesn't connect in that direction, create path

**Path Generation Rules**:
- If tile belongs to cell A and neighbor belongs to cell B with different groups → PATH
- If tile belongs to cell A and cell A doesn't connect UP → PATH above
- If tile is BLANK but neighbors have paths and cells don't connect → PATH

#### Step 4: Handle Tunnels

For cells marked `topTunnel`:
- Set tiles at tunnel exit position to `PATH`
- Extends 2 tiles to the right (tunnel opening)

#### Step 5: Generate Walls

For all non-path tiles:
- If adjacent (including diagonals) to any PATH tile → `WALL`
- Creates wall boundaries around all paths

#### Step 6: Special Elements

**Ghost Wall**:
- Fixed position: `[2, 12]` → `GHOSTWALL`
- Allows ghosts to pass through

**Energizers**:
- **Top energizer**: Placed in right column, upper half
  - Finds valid range (2 consecutive PATH tiles)
  - Randomly selects Y position within range
- **Bottom energizer**: Placed in right column, lower half
  - Similar logic for bottom half

#### Step 7: Erase Dead Ends

For paths in the rightmost column:
- If path has only 1 adjacent path → erase until intersection
- Prevents isolated dead-end tunnels

#### Step 8: Set Tunnel Areas

Marks tunnel areas as `PATHBLANK` (no pellets):
- Left tunnel area: `[1, subHeight - 8]`
- Additional tunnel areas based on wall patterns
- Extends tunnel paths vertically/horizontally where walls block both sides

---

## Core Algorithms

### Leftmost Empty Cell Selection

```gml
function pacman_map_get_leftmost_empty_cells() {
    result = []
    for x = 0 to CELL_MAP_SIZE_X - 1:
        for y = 0 to CELL_MAP_SIZE_Y - 1:
            if cellMap[x][y] is not filled:
                add to result
        if result is not empty:
            break  // Found leftmost column with empty cells
    return result
}
```

**Purpose**: Ensures left-to-right filling order, creating natural maze progression.

---

### Open Direction Detection

```gml
function Cell_isOpen(cell, dir, prevDir, size) {
    // Special case: ghost space barrier
    if (cell at [0,6] and dir == DOWN) return false
    if (cell at [0,7] and dir == UP) return false
    
    // Prevent backtracking for size 2 pieces
    if (size == 2 and (dir == prevDir or opposite(dir) == prevDir)):
        return false
    
    // Check if neighbor exists and is unfilled
    neighbor = cell.next[dir]
    if (neighbor == noone or neighbor.filled):
        return false
    
    // Check if cell to left of neighbor is filled (prevents gaps)
    leftNeighbor = neighbor.next[LEFT]
    if (leftNeighbor != noone and !leftNeighbor.filled):
        return false  // Would create gap
    
    return true
}
```

**Purpose**: Determines valid directions for piece growth while maintaining maze integrity.

---

### Resize Candidate Detection

**Raise Height Candidates**:
- Cell at left edge OR no LEFT connection
- Cell at right edge OR no RIGHT connection
- Exactly one of UP/DOWN connected (not both, not neither)

**Shrink Width Candidates**:
- Cell at right edge AND connects RIGHT
- OR: Cell at top/bottom edge OR no UP/DOWN connection
- Exactly one of LEFT/RIGHT connected

**Purpose**: Identifies cells suitable for size variation to add visual interest.

---

### Stacked Piece Detection

**Horizontal Stacking**:
```gml
Cell[i][j] and Cell[i+1][j] form horizontal stack if:
    - Cell[i][j]: no UP/DOWN, no LEFT (or at edge), connects RIGHT
    - Cell[i+1][j]: no UP/DOWN, connects LEFT, no RIGHT
```

**Vertical Stacking**:
```gml
Cell[i][j] and Cell[i][j+1] form vertical stack if:
    - Cell[i][j]: no LEFT/RIGHT, no UP, connects DOWN
    - Cell[i][j+1]: no LEFT/RIGHT, connects UP, no DOWN
```

**Handling**: If found at left edge, reject maze. Otherwise, join into single group.

---

## Pacman Compliance Features

### 1. Symmetry

The maze is **horizontally symmetrical** (left mirrors right):
- Tile map is doubled: `fullWidth = (subWidth - 2) * 2`
- All tile operations use `pacman_map_set_tile()` which sets both sides
- Ensures balanced gameplay

### 2. Ghost Space

**Location**: Top-left corner (cells [0,3], [1,3], [0,4], [1,4])

**Properties**:
- Pre-filled during initialization
- Connected to allow ghost movement
- Marked as `GHOSTSPACE` tile type
- Not part of main maze generation

### 3. Side Tunnels

**Purpose**: Allow wraparound navigation (classic Pacman mechanic)

**Requirements**:
- At least 1 tunnel, optionally 2
- Must not create trivial horizontal paths
- Tunnels marked as `PATHBLANK` (no pellets)

### 4. Energizers

**Placement**:
- One in upper half, one in lower half
- Always in right column (symmetrical to left column)
- Placed on valid path tiles (2 consecutive PATH tiles required)

### 5. Wall Connectivity

**Ghost Wall**:
- Special wall type at fixed position
- Ghosts can pass through, Pacman cannot

**Wall Generation**:
- All non-path tiles adjacent to paths become walls
- Wall sprite selection based on neighbor patterns (see `pacman_map_calculate_wall_tile`)

### 6. Path Requirements

**Pellet Paths** (`PATH`):
- Most walkable areas contain pellets
- Generated along group boundaries and cell connections

**Tunnel Paths** (`PATHBLANK`):
- Side tunnels and connecting areas
- No pellets (empty paths)

---

## Code Walkthrough

### Main Generation Function

```gml
function pacman_map_generate() {
    while (true) {
        pacman_map_reset();
        pacman_map_attempt_generate();
        
        if (!pacman_map_is_desirable()) {
            continue;  // Restart if quality check fails
        }
        
        pacman_map_setup_scale_coords();
        pacman_map_join_walls();
        
        if (!pacman_map_create_tunnels()) {
            continue;  // Restart if tunnels can't be created
        }
        
        break;  // Success!
    }
}
```

**Key Points**:
- Uses retry loop until valid maze is generated
- Quality checks happen before expensive operations
- Tunnel creation is final validation step

---

### Piece Growth Example

```gml
// Start with cell at [0, 2]
cell = cellMap[0][2]
Cell_fill(cell, groupID = 0)
size = 1

// Grow to size 2
openDirs = cell.getOpenCells(-1, 1)  // [RIGHT]
dir = RIGHT
cell.connect(RIGHT)
newCell = cell.next[RIGHT]  // [1, 2]
Cell_fill(newCell, 0)
size = 2

// Check stop probability: random() < 0.1? (10% chance)
// If continues, grow to size 3
openDirs = newCell.getOpenCells(RIGHT, 2)  // [UP]
dir = UP
newCell.connect(UP)
newCell = newCell.next[UP]  // [1, 1]
Cell_fill(newCell, 0)
size = 3

// Check stop probability: random() < 0.5? (50% chance)
// If stops, piece is complete
```

---

### Tunnel Creation Example

```gml
// Analyze right column
for j = 0 to 8:
    c = cellMap[4][j]
    
    // Check if void tunnel candidate
    if (c.connections[RIGHT] and 
        (c.next[UP].connections[RIGHT] or c.next[DOWN].connections[RIGHT])):
        add to voidTunnelCells
    
    // Check if single dead end
    if (!c.connections[RIGHT] and !c.connections[DOWN]):
        upDead = c.next[UP].connections[RIGHT]
        downDead = c.next[DOWN].connections[RIGHT]
        if (upDead != downDead):  // Exactly one is dead
            add to singleDeadEndCells

// Select tunnel
if (random() <= 0.45):  // 45% chance for 2 tunnels
    // Create top and bottom tunnels
else:  // 55% chance for 1 tunnel
    // Select from voidTunnelCells or singleDeadEndCells
```

---

## Troubleshooting

### Common Issues

**1. Generation Loops Forever**
- **Cause**: Quality checks too strict or tunnel candidates unavailable
- **Solution**: Check `pacman_map_is_desirable()` logic, verify tunnel candidate detection

**2. Missing Tunnels**
- **Cause**: No valid tunnel candidates found
- **Solution**: Verify right column cell connections, check candidate classification logic

**3. Invalid Symmetry**
- **Cause**: Tile operations not using `pacman_map_set_tile()`
- **Solution**: Ensure all tile state changes use the symmetric setter

**4. Energizers Not Placing**
- **Cause**: No valid range found (requires 2 consecutive PATH tiles)
- **Solution**: Check path generation, verify right column has paths

**5. Walls Not Connecting**
- **Cause**: Path generation incomplete or group boundaries incorrect
- **Solution**: Verify group assignment, check path generation rules

### Debugging Tips

1. **Use ASCII Output**: Call `pacman_map_print_ascii(tileMap)` to visualize the maze
2. **Check Cell Map**: Inspect `cellMap` after generation to verify structure
3. **Validate Groups**: Ensure all cells have valid group IDs
4. **Trace Tunnel Selection**: Add debug output in `pacman_map_create_tunnels()`
5. **Verify Coordinates**: Check `tilePosition` and `tileSize` after scaling

---

## Performance Considerations

### Generation Time

- **Average**: 1-5 iterations to generate valid maze
- **Worst Case**: May require 10+ iterations if constraints are tight
- **Optimization**: Quality checks happen early to avoid expensive operations

### Memory Usage

- **Cell Map**: 5 × 9 = 45 cells
- **Tile Map**: ~34 × 31 = ~1,054 tiles
- **Total**: Minimal memory footprint

### Retry Strategy

The system uses a simple retry loop. For production use, consider:
- Maximum retry limit (e.g., 100 attempts)
- Progressive relaxation of constraints
- Fallback to simpler generation if retries exceed limit

---

## Extension Points

### Customizing Maze Size

To change maze dimensions:
1. Update `CELL_MAP_SIZE_X` and `CELL_MAP_SIZE_Y` macros
2. Adjust ghost space coordinates in `pacman_map_reset()`
3. Update tile map size calculations in `pacman_map_get_tile_map()`
4. Verify tunnel candidate ranges

### Adding New Tile Types

1. Add enum value to `TileState`
2. Update `pacman_map_get_tile_map()` to handle new type
3. Update `pacman_map_calculate_wall_tile()` if affects wall logic
4. Update sprite mapping in `pacman_map_get_sprite_map_index()`

### Modifying Generation Parameters

Key parameters in `pacman_map_attempt_generate()`:
- `probStopGrowingAtSize`: Controls piece size distribution
- `probTopAndBotSingleCellJoin`: Controls top/bottom single cells
- `probExtendAtSize2`: Controls size 2 extensions
- `probExtendAtSize3or4`: Controls size 3/4 extensions
- `MAX_LONG_PIECES`: Limits long horizontal pieces

Adjust these to change maze characteristics.

---

## Conclusion

This Pacman maze generation system creates procedurally-generated mazes that maintain the classic Pacman aesthetic while providing variety through randomization. The two-stage approach (cell map → tile map) allows for efficient generation while ensuring compliance with Pacman design requirements.

For questions or issues, refer to the code comments or this guide's troubleshooting section.





