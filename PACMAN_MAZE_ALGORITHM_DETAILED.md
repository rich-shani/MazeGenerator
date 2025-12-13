# How the Pacman Maze is Created - A Simple Explanation

## The Big Picture

Imagine you're building a Pacman maze. Instead of designing it tile by tile (which would be 28 tiles wide by 31 tiles tall - that's 868 tiles!), this algorithm works smarter. It starts with a small grid of just 45 "cells" (5 columns by 9 rows), then expands each cell into a 3×3 block of tiles. Think of it like building with LEGO blocks - you design with big blocks first, then each big block becomes 9 small tiles.

The whole process happens in stages, like building a house: first the foundation (cells), then the structure (connections), then the details (paths and walls), and finally the decorations (tunnels and energizers).

---

## Stage 1: Setting Up the Foundation

### What is a Cell?

A cell is like a building block. Each cell knows:
- **Where it is** in the 5×9 grid (like coordinates on a map)
- **Which neighbors it has** (up, down, left, right - like knowing your neighbors)
- **Whether it's part of the maze yet** (filled or empty)
- **How it connects to other cells** (which directions have paths)

Think of it like a room in a house - it knows which rooms are next to it, and which doors are open.

### Creating the Grid

First, we create a 5×9 grid of empty cells. Each cell is like an empty lot. We also set up the "ghost house" area - this is a special area in the bottom-left where the ghosts start. We mark those cells as already filled, like reserving parking spaces.

---

## Stage 2: Building the Maze Pieces

### The Left-to-Right Approach

The algorithm builds the maze like reading a book - from left to right, one piece at a time. Each "piece" is a group of connected cells that form part of the maze.

Here's how it works:

1. **Find the leftmost empty cells** - Look at the leftmost column, find all cells that aren't part of the maze yet
2. **Pick one randomly** - Choose any empty cell from that leftmost column
3. **Start growing a piece** - From that cell, start connecting to nearby empty cells
4. **Keep growing** - Each time you add a cell, randomly decide whether to keep growing or stop
5. **Repeat** - Once a piece is done, go back to step 1 and start a new piece

### How Pieces Grow

When a piece starts growing, it's like a plant spreading. The algorithm looks at all possible directions (up, down, left, right) and picks one randomly. But there are rules:

- **Can't go backwards** - If you just came from the left, you can't immediately go back left
- **Can't go into filled cells** - You can only connect to empty cells
- **Can't make paths too wide** - This prevents the maze from having huge open areas

The piece keeps growing until:
- It runs out of valid directions (hit a wall or filled cells)
- It reaches a certain size (usually 1-4 cells)
- A random chance says "stop" (bigger pieces have higher chances to stop)

### Example: Growing a Piece

Let's say we start at cell (0, 2) - that's column 0, row 2:

1. Cell (0, 2) is marked as filled
2. It looks around: can go RIGHT or DOWN
3. Randomly picks RIGHT → connects to cell (1, 2)
4. Now at cell (1, 2), looks around: can go RIGHT, UP, or DOWN
5. Randomly picks UP → connects to cell (1, 1)
6. Now at cell (1, 1), looks around: can go RIGHT or UP
7. Randomly picks RIGHT → connects to cell (2, 1)
8. Random chance says "stop" → piece is done

Result: A 4-cell piece shaped like an "L" going up and right.

### Special Cases

**Right Edge Cells**: When a piece reaches the rightmost column, it automatically connects to create the wrap-around tunnel (like Pacman going off the right side and appearing on the left).

**Long Pieces**: Sometimes, a small 2-cell piece gets extended into a longer piece. This creates variety in the maze layout.

---

## Stage 3: Checking Quality

After all pieces are created, the algorithm checks if the maze is "good enough." It's like a quality inspector:

### Corner Checks

The top-right and bottom-right corners must be dead ends (no connections up or right). This ensures the maze has proper corners like classic Pacman mazes.

### Stacked Pieces

Sometimes, two pieces end up stacked on top of each other (like two horizontal bars, one above the other). The algorithm detects this and joins them together, creating a more interesting structure.

If the maze doesn't pass these checks, the whole thing is thrown away and we start over. This might happen many times until we get a good maze!

---

## Stage 4: Adding Variety

To make mazes look different each time, some cells are made taller or narrower:

### Tall Rows

Some cells can be made 4 tiles tall instead of the normal 3. This creates vertical variety - like having some rooms with high ceilings. The algorithm looks for good candidates (usually in the leftmost column) and picks one to make tall.

### Narrow Columns

Some cells can be made 2 tiles wide instead of 3. This creates horizontal variety - like having some narrow hallways. The algorithm looks for good candidates (usually in the top row) and picks one to make narrow.

These changes make each maze unique while still following the same rules.

---

## Stage 5: Mapping to Tiles

Now we need to figure out where each cell will be in the final tile map. Remember, each cell becomes a 3×3 block of tiles (or 2×3 if narrow, or 3×4 if tall).

### The Math

- **Base position**: Multiply the cell's position by 3
  - Cell at (1, 2) → starts at tile position (3, 6)
- **Adjust for narrow columns**: If there's a narrow column in this row, shift left by 1
- **Adjust for tall rows**: If there's a tall row in this column, shift down by 1

### Example

Cell at (2, 3):
- Base: (2 × 3, 3 × 3) = (6, 9)
- If narrow column at row 3: becomes (5, 9)
- If tall row at column 2: becomes (5, 10)
- Final size: 3×3 tiles (or 2×3 if narrow, or 3×4 if tall)

---

## Stage 6: Joining Walls

Sometimes, the algorithm adds extra connections to join walls together. This is like adding decorative arches between rooms - it makes the maze look more cohesive. These connections happen randomly (about 25% chance) at the edges of the maze.

---

## Stage 7: Creating Tunnels

Pacman mazes need tunnels on the sides so you can wrap around (go off one side and appear on the other). The algorithm looks at the rightmost column and finds good spots for tunnels.

### Finding Tunnel Spots

The algorithm scans the right edge looking for:
- **Void tunnels**: Places where there's a path but it's a dead end above or below
- **Single dead ends**: Cells that only connect in one direction
- **Edge tunnels**: Cells near the top or bottom edges

### Choosing Tunnels

The algorithm randomly decides: 1 tunnel or 2 tunnels? (45% chance of 2 tunnels)

If 1 tunnel: Prefers void tunnels, then single dead ends, then edge tunnels
If 2 tunnels: Tries to create one near the top and one near the bottom

Once a tunnel spot is chosen, it's marked. Later, this will create an actual path through the right edge.

---

## Stage 8: Creating the Tile Map

Now we create the actual 28×31 grid of tiles. This is like taking our blueprint (the cell map) and actually building the maze.

### Setting Up the Grid

We create a 28×31 array of tiles. The maze is symmetric (mirrored left and right), so we only design half of it, then mirror it.

### Mapping Cells to Tiles

For each cell, we fill in all the tiles it occupies:

- A normal cell (3×3) fills 9 tiles
- A narrow cell (2×3) fills 6 tiles  
- A tall cell (3×4) fills 12 tiles

Each tile remembers which cell it came from, like each brick in a wall knowing which room it belongs to.

---

## Stage 9: Drawing Paths and Walls

Now we decide which tiles are paths (where Pacman can walk) and which are walls.

### Creating Paths

Paths are created where:
- **Cells connect**: If two cells are connected, the tiles between them become paths
- **Different groups meet**: If two cells belong to different groups, they need a path between them
- **Cell has an opening**: If a cell doesn't connect upward, the top tiles become paths

Think of it like this: if two rooms have a door between them, the hallway connecting them is a path.

### Creating Walls

After paths are drawn, everything else that's next to a path becomes a wall. It's like building walls around your paths - if there's a walkable area, put walls around it.

The algorithm checks each tile: "Am I next to a path? If yes, I'm a wall."

### Special Elements

**Ghost House**: The ghost house area is marked as a special tile type (GHOSTSPACE). This is where ghosts spawn.

**Tunnels**: The tunnel spots we marked earlier now become actual paths. These are special paths that allow wrap-around movement.

**Energizers**: Two energizers (power pellets) are placed - one in the top half, one in the bottom half. They're placed in valid path locations where there's enough space.

**Path Blanks**: Dead-end paths (paths that only go one way and end) are converted to "path blanks" - these are walkable but don't have pellets. This creates the tunnel effect where you can walk but there are no dots.

### Symmetry

Everything is mirrored. When we set a tile on the right side, we automatically set the corresponding tile on the left side. This creates the classic symmetric Pacman maze look.

---

## A Complete Example

Let's trace through a simple example:

### Step 1: Cell Generation
- Start with empty 5×9 grid
- Create piece 1: cells (0,2) → (1,2) → (1,1) → (2,1) [4 cells, L-shaped]
- Create piece 2: cells (0,4) → (1,4) [2 cells, horizontal]
- Create piece 3: cells (2,3) → (3,3) → (3,4) [3 cells, L-shaped]
- ... and so on until all cells are filled

### Step 2: Quality Check
- Check corners: ✓ Top-right and bottom-right are dead ends
- Check for stacked pieces: Found two stacked pieces, joined them
- Check tall/narrow candidates: Found one tall row candidate, one narrow column candidate
- Maze passes! ✓

### Step 3: Resizing
- Cell (0, 1) is made tall (4 tiles instead of 3)
- Cell (3, 0) is made narrow (2 tiles instead of 3)

### Step 4: Coordinate Mapping
- Cell (0, 1): position (0, 3), size 3×4 (tall)
- Cell (1, 2): position (3, 6), size 3×3 (normal)
- Cell (3, 0): position (8, 0), size 2×3 (narrow)
- ... and so on

### Step 5: Tunnel Creation
- Scanned right edge, found void tunnel candidate at cell (4, 3)
- Randomly decided: 1 tunnel
- Marked cell (4, 3) as tunnel

### Step 6: Tile Map Creation
- Created 28×31 tile grid
- Mapped each cell to its tile region
- Cell (1, 2) occupies tiles (3,7) through (5,9)

### Step 7: Path and Wall Generation
- Where cells connect → paths
- Where different groups meet → paths
- Everything adjacent to paths → walls
- Tunnel at (4, 3) → path created
- Two energizers placed
- Dead ends converted to path blanks

### Step 8: Symmetry
- Everything mirrored to left side
- Final maze complete!

---

## Why This Approach Works

This algorithm is clever because:

1. **It's efficient**: Instead of placing 868 tiles individually, we work with 45 cells
2. **It's flexible**: The random choices create different mazes each time
3. **It's validated**: Quality checks ensure every maze is playable
4. **It's authentic**: The left-to-right approach mimics how classic Pacman mazes were designed
5. **It's detailed**: The final tile map has all the game elements (paths, walls, tunnels, energizers)

The result is a procedurally generated maze that looks and plays like a classic Pacman maze, but is different every time you run it!

---

## Summary: The Journey from Cells to Tiles

1. **Start small**: Create a 5×9 grid of cells
2. **Build pieces**: Grow connected pieces from left to right
3. **Check quality**: Make sure the maze is good
4. **Add variety**: Make some cells tall or narrow
5. **Map coordinates**: Figure out where each cell goes in the tile map
6. **Join walls**: Add extra connections for cohesion
7. **Create tunnels**: Add wrap-around paths
8. **Build tiles**: Create the 28×31 tile grid
9. **Draw paths**: Mark where Pacman can walk
10. **Draw walls**: Mark where walls go
11. **Add details**: Place energizers, mark ghost house, create path blanks
12. **Mirror**: Create symmetric left side

And voilà! You have a complete Pacman maze, ready to play!
