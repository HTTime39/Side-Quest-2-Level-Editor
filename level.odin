package main

import "core:encoding/json"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"

// -----------------------------------------------------------------------------
// LEVEL  --  read the LDtk project, keep only what the game needs.
//
//   Ldtk_*  mirrors the AUTHORING format: LDtk's JSON, field names and all.
//   Level   is the RUNTIME format: plain arrays the game can use directly.
// load_level is the only code that knows both.
// -----------------------------------------------------------------------------

LEVEL_PATH :: #directory + "/levels/level.ldtk"

// --- authoring format: only the fields we read; the JSON reader skips the rest.
// The text in backquotes is the name of the field IN THE FILE.

Ldtk_Project :: struct {
	levels: []Ldtk_Level,
}

Ldtk_Level :: struct {
	layers: []Ldtk_Layer `json:"layerInstances"`, // TOP layer first
}

Ldtk_Layer :: struct {
	identifier: string `json:"__identifier"`, // the layer's NAME in LDtk
	cols:       int `json:"__cWid"`, // width in cells
	rows:       int `json:"__cHei"`, // height in cells
	grid:       int `json:"__gridSize"`, // size of one cell, in pixels
	int_grid:   []int `json:"intGridCsv"`, // IntGrid layers: one number per cell, row by row
	tiles:      []Ldtk_Tile `json:"gridTiles"`, // Tiles layers: the tiles you painted
	auto_tiles: []Ldtk_Tile `json:"autoLayerTiles"`, // tiles made by auto-layer rules (optional)
	entities:   []Ldtk_Entity `json:"entityInstances"`, // Entities layers
}

// One painted tile: WHERE it goes (px) and WHICH part of the tileset (src). Pixels.
Ldtk_Tile :: struct {
	px:  [2]f32,
	src: [2]f32,
	f:   int, // flip bits: 1 = mirrored in x, 2 = mirrored in y
}

// One placed entity: its NAME in LDtk and the CELL it sits in (column, row).
Ldtk_Entity :: struct {
	identifier: string `json:"__identifier"`,
	cell:       [2]int `json:"__grid"`,
}

// --- runtime format

Tile_Draw :: struct {
	src: rl.Rectangle, // which rectangle of the tileset
	pos: rl.Vector2, // where in the world
}

Level :: struct {
	tiles:      [dynamic]Tile_Draw, // what to draw, back to front
	solid:      []bool, // cols * rows, row by row: is this cell a wall?
	cols, rows: int,
	grid:       f32,
	start:      rl.Vector2, // centre of the PlayerStart cell
	coins:      [dynamic]rl.Vector2, // centre of every Coin cell
  flowers:    [dynamic]rl.Vector2,
}

load_level :: proc() -> (lv: Level, ok: bool) {
	// 1. READ the file: bytes from disk.
	data, read_err := os.read_entire_file_from_path(LEVEL_PATH, context.temp_allocator)
	if read_err != nil {
		fmt.eprintln("cannot read", LEVEL_PATH)
		return
	}

	// 2. PARSE: fill the Ldtk_* structs from the JSON text.
	project: Ldtk_Project
	if err := json.unmarshal(data, &project, allocator = context.temp_allocator); err != nil {
		fmt.eprintln("bad level file:", err)
		return
	}
	if len(project.levels) == 0 {
		fmt.eprintln("the project has no level")
		return
	}
	layers := project.levels[0].layers

	// 3. CONVERT: LDtk lists the TOP layer first; we draw the BOTTOM first,
	// so walk the list backwards.
	#reverse for layer in layers {
		size := f32(layer.grid)

		// Any layer may carry tiles: painted ones, or ones an auto-layer made.
		for t in layer.auto_tiles do append(&lv.tiles, tile_draw(t, size))
		for t in layer.tiles do append(&lv.tiles, tile_draw(t, size))

		switch layer.identifier {
		case "Walls":
			// TODO 4: fill lv.solid - one bool per cell, true when the cell is a wall.
			//   - copy the size first:  lv.cols, lv.rows, lv.grid = layer.cols, layer.rows, size
      lv.cols, lv.rows, lv.grid = layer.cols, layer.rows, size
			//   - make the array:       lv.solid = make([]bool, len(layer.int_grid))
      lv.solid = make([]bool, len(layer.int_grid))
			//   - layer.int_grid holds one number per cell, row by row. In LDtk you
			//     painted walls with the value 1; every other cell is 0.
      for value, i in layer.int_grid {
        lv.solid[i] = value == 1
      }
			// Check it: press F1 in the game. Every wall cell gets a red outline.

		case "Entities":
			// TODO 5: walk layer.entities. Each one has a name (e.identifier) and a
			// cell (e.cell). cell_centre(e.cell, size) gives its world position.
			//   - "PlayerStart" -> lv.start
			//   - every "Coin"  -> append(&lv.coins, ...)
      for entity in layer.entities {
        if entity.identifier == "PlayerStart" {
		      lv.start = cell_centre(entity.cell, size)
        } else if entity.identifier == "Coin" {
          append(&lv.coins, cell_centre(entity.cell, size))
        } else if entity.identifier == "Flower" {
          append(&lv.flowers, cell_centre(entity.cell, 16))
        }
      }
			// Check it: the player appears where you put PlayerStart, and a gold
			// circle appears on every Coin.
		}
	}
	return lv, true
}

unload_level :: proc(lv: ^Level) {
	delete(lv.tiles)
	delete(lv.solid)
	delete(lv.coins)
	lv^ = {}
}

// One LDtk tile -> one thing to draw. A negative size reads the tile mirrored.
tile_draw :: proc(t: Ldtk_Tile, size: f32) -> Tile_Draw {
	return {
		src = {t.src.x, t.src.y, (t.f & 1 != 0) ? -size : size, (t.f & 2 != 0) ? -size : size},
		pos = t.px,
	}
}

// The middle of a cell, in world pixels.
cell_centre :: proc(cell: [2]int, size: f32) -> rl.Vector2 {
	return {(f32(cell.x) + 0.5) * size, (f32(cell.y) + 0.5) * size}
}

// Is there a wall at this world position? Outside the level counts as a wall.
solid_at :: proc(lv: ^Level, p: rl.Vector2) -> bool {
	if lv.solid == nil do return false // no Walls layer read yet: nothing blocks
	col := int(p.x / lv.grid)
	row := int(p.y / lv.grid)
	if p.x < 0 || p.y < 0 || col >= lv.cols || row >= lv.rows do return true
	return lv.solid[row * lv.cols + col]
}
