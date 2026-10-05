package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

// ldtk-level: Side Quest SQ1 - the level pipeline.
// Draw a tileset, paint a level with it in LDtk, and make this game read it.
//   TODO 1-2: outside the code - your tileset and your LDtk level (README.md)
//   TODO 3, 6, 7, 8: in this file
//   TODO 4, 5: in level.odin
//   TODO 9: one thing of your own (README.md)
// It runs before you do anything: a blue square on an empty screen.

WINDOW_W :: 1280
WINDOW_H :: 720
ZOOM :: 4 // each art pixel becomes a 4x4 block on screen - whole numbers only
TILE :: 16 // one tile of YOUR tileset, in pixels. Must match the LDtk grid.
SPEED :: 70.0 // world pixels per second

TILES_PATH :: #directory + "/assets/tiles.png"
HERO_PATH :: #directory + "/assets/hero.png"

HALF :: rl.Vector2{5, 5} // half the player's collision box, in world pixels
COIN_REACH :: 9.0 // how close the player must be to take a coin

Player :: struct {
	pos: rl.Vector2, // the CENTRE of the character, in world pixels
}

// May a box centred at `centre` be here? Test its four corners.
can_be_at :: proc(lv: ^Level, centre: rl.Vector2) -> bool {
	for dx in ([]f32{-HALF.x, HALF.x}) {
		for dy in ([]f32{-HALF.y, HALF.y}) {
			if solid_at(lv, centre + {dx, dy}) do return false
		}
	}
	return true
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_W, WINDOW_H, "ldtk-level")
	defer rl.CloseWindow()

	// TODO 3: load your tileset ONCE, here - never inside the loop.
	// tiles := rl.LoadTexture(TILES_PATH)
	// defer rl.UnloadTexture(tiles)
	// Optional: your hero.png from sprite-hero, the same way.
	// hero := rl.LoadTexture(HERO_PATH)
	// defer rl.UnloadTexture(hero)

	level, level_ok := load_level()
	defer unload_level(&level)

	player := Player {
		pos = level.start,
	}
	cam := rl.Camera2D {
		offset = {WINDOW_W / 2, WINDOW_H / 2},
		target = player.pos,
		zoom   = ZOOM,
	}
	total_coins := len(level.coins)
	debug := false

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// 1. INPUT
		move: rl.Vector2
		if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do move.x -= 1
		if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do move.x += 1
		if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do move.y -= 1
		if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do move.y += 1
		move = linalg.normalize0(move)
		if rl.IsKeyPressed(.F1) do debug = !debug

		// F5: the level changed on disk, read it again. The ONE time loading
		// inside the loop is right - on a key press, not every frame.
		if rl.IsKeyPressed(.F5) {
			if fresh, fresh_ok := load_level(); fresh_ok {
				unload_level(&level)
				level, level_ok = fresh, true
				player.pos = level.start
				total_coins = len(level.coins)
			}
		}

		// 2. UPDATE
		step := move * SPEED * dt

		// TODO 7: right now the player walks through walls. Only take the step
		// if can_be_at(&level, <the new position>) says yes. Do x and y
		// separately, so the player slides along a wall instead of sticking.
		player.pos += step

		// TODO 8: take every coin the player is close enough to (COIN_REACH).
		// linalg.distance(a, b) is the distance between two points;
		// unordered_remove(&level.coins, i) removes coin i. Loop BACKWARDS
		// (#reverse for coin, i in level.coins) when you remove while looping.

		// Follow the player. Snap to whole SCREEN pixels so tiles do not shimmer.
		cam.target = {math.round(player.pos.x * ZOOM) / ZOOM, math.round(player.pos.y * ZOOM) / ZOOM}

		// 3. DRAW - back to front
		rl.BeginDrawing()
		rl.ClearBackground({24, 20, 37, 255})
		rl.BeginMode2D(cam)

		// TODO 6: draw the level. For every t in level.tiles, draw the
		// rectangle t.src of your tileset at t.pos:
		//     rl.DrawTextureRec(tiles, t.src, t.pos, rl.WHITE)

		for coin in level.coins do rl.DrawCircleV(coin, 4, rl.GOLD)

		// The player. Optional: draw your hero.png instead of the square:
		//     w, h := f32(hero.width), f32(hero.height)
		//     rl.DrawTexturePro(hero, {0, 0, w, h}, {player.pos.x, player.pos.y, w, h}, {w / 2, h / 2}, 0, rl.WHITE)
		rl.DrawRectangleV(player.pos - HALF, HALF * 2, rl.BLUE)

		if debug {
			for solid, i in level.solid {
				if !solid do continue
				x, y := f32(i % level.cols) * level.grid, f32(i / level.cols) * level.grid
				rl.DrawRectangleLinesEx({x, y, level.grid, level.grid}, 0.5, rl.RED)
			}
			rl.DrawRectangleLinesEx({player.pos.x - HALF.x, player.pos.y - HALF.y, HALF.x * 2, HALF.y * 2}, 0.5, rl.YELLOW)
		}
		rl.EndMode2D()

		// HUD: screen space, after EndMode2D
		if !level_ok {
			rl.DrawText("No level yet: paint one in LDtk and save it as levels/level.ldtk", 16, 16, 24, rl.WHITE)
		} else {
			rl.DrawText(fmt.ctprintf("coins %d / %d", total_coins - len(level.coins), total_coins), 16, 16, 30, rl.WHITE)
		}
		rl.DrawText("WASD / arrows: move   F1: debug   F5: reload the level", 16, WINDOW_H - 36, 20, rl.LIGHTGRAY)
		rl.EndDrawing()
	}
}
