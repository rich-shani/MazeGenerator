# Pac-Man Maze Generator

A procedural maze generation system for GameMaker Studio that creates Pac-Man-compliant mazes with classic gameplay features.

## Overview

This project generates procedurally-created Pac-Man style mazes using a sophisticated two-stage approach:
1. **Cell Map Generation**: Creates a 5×9 grid of cells representing high-level maze structure
2. **Tile Map Conversion**: Converts cells into a detailed tile map with walls, paths, and game elements

Each generated maze maintains classic Pac-Man characteristics including symmetry, side tunnels, ghost spawn areas, and strategic power pellet placement.

## Features

- 🎮 **Procedural Generation**: Every maze is unique while maintaining Pac-Man design principles
- 🔄 **Symmetrical Design**: Left-right mirroring for balanced gameplay
- 🚇 **Side Tunnels**: Wraparound navigation tunnels (1-2 per maze)
- 👻 **Ghost Spawn Area**: Pre-configured ghost home area in the top-left corner
- ⚡ **Energizers**: Strategic power pellet placement in upper and lower halves
- 🧱 **Smart Wall Generation**: Properly connected walls with visual consistency
- ✅ **Quality Validation**: Ensures generated mazes meet gameplay requirements

## Requirements

- **GameMaker Studio** (2024.14.0.207 or compatible)
- No external dependencies required

## Project Structure

```
MazeGenerator/
├── objects/
│   ├── oMazeGenerator/     # Main maze generator object
│   ├── Dot/                # Pellet object
│   ├── Pill/               # Power pellet object
│   └── Wall/               # Wall object
├── scripts/
│   ├── pacman_maze/        # Core maze generation system
│   ├── Cell/               # Cell data structure
│   ├── Tile/               # Tile data structure
│   ├── Map/                # Map utilities
│   ├── ArrayFns/           # Array helper functions
│   ├── DirectionFns/       # Direction utilities
│   └── TupleFns/           # Tuple utilities
├── sprites/
│   ├── sDot/               # Pellet sprite
│   ├── sPill/              # Power pellet sprite
│   └── sWall/              # Wall sprite
└── rooms/
    └── Room1/              # Main room
```

## Usage

### Basic Usage

1. Open the project in GameMaker Studio
2. Run the project (F5)
3. The maze will be automatically generated when `oMazeGenerator` is created
4. The maze is printed to the console in ASCII format

### Programmatic Usage

```gml
// Generate a new maze
pacman_map_generate();

// Get the tile map
var tileMap = pacman_map_get_tile_map();

// Get sprite map for rendering
var spriteMapJson = pacman_map_get_sprite_map_index(tileMap);
var mapData = json_parse(spriteMapJson);
```

### Customization

The generation system uses several configurable parameters:

- **Cell Map Size**: `CELL_MAP_SIZE_X = 5`, `CELL_MAP_SIZE_Y = 9`
- **Piece Growth Probabilities**: Controls maze structure complexity
- **Tunnel Count**: Randomly generates 1-2 tunnels per maze
- **Tall Rows & Narrow Columns**: Adds visual variety to maze structure

See `PACMAN_MAZE_DEVELOPER_GUIDE.md` for detailed customization options.

## Maze Specifications

- **Cell Map**: 5 columns × 9 rows
- **Tile Map**: ~34 columns × 31 rows (symmetrical)
- **Cell-to-Tile Scale**: Each cell represents 3×3 tiles (with variations)
- **Symmetry**: Full horizontal symmetry (left mirrors right)

## Technical Details

The generation pipeline consists of 7 phases:

1. **Initialization**: Create cell map and establish neighbor relationships
2. **Structure Generation**: Build maze using left-to-right filling strategy
3. **Quality Validation**: Ensure maze meets design requirements
4. **Coordinate Scaling**: Convert cell coordinates to tile coordinates
5. **Wall Joining**: Improve visual consistency
6. **Tunnel Creation**: Add side tunnels for wraparound navigation
7. **Tile Map Generation**: Convert to final tile map with all game elements

For in-depth technical documentation, see [PACMAN_MAZE_DEVELOPER_GUIDE.md](PACMAN_MAZE_DEVELOPER_GUIDE.md).

## Tile Types

The system supports the following tile states:

- `BLANK` - Empty/void space (not walkable)
- `PATH` - Walkable path with pellet
- `PATHBLANK` - Walkable path without pellet (tunnel)
- `WALL` - Solid wall
- `GHOSTWALL` - Wall ghosts can pass through
- `ENERGIZER` - Power pellet location
- `GHOSTSPACE` - Ghost spawn/home area

## Performance

- **Average Generation Time**: 1-5 iterations
- **Memory Footprint**: Minimal (~45 cells + ~1,054 tiles)
- **Retry Strategy**: Automatic retry until valid maze is generated

## Documentation

- **[Developer Guide](PACMAN_MAZE_DEVELOPER_GUIDE.md)**: Comprehensive technical documentation covering architecture, algorithms, and code walkthrough

## License

This project is provided as-is. Feel free to use and modify for your own projects.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Acknowledgments

Inspired by classic Pac-Man maze design principles.

