# ldtk-level — Side Quest SQ1 (5 pts): the level pipeline

CSCI 4160U - Game Development · Stage 4, Chapter 8 · started in class Mon Oct 5 ·
**due Sun Oct 18, 23:59**

You will take one level through the whole pipeline, by hand, once:

```text
draw a tileset  ->  paint a level in LDtk  ->  level.ldtk  ->  this game reads it  ->  raylib draws it
  (Pixelorama)         (LDtk)                   (a file)        (level.odin)           (main.odin)
```

At the end you walk your own character around a level you painted, made of
tiles you drew, bumping into the walls you marked and picking up the coins you
placed. **No tile position, wall or coin is typed into the code.**

Art is never graded. Ugly tiles that are yours are worth full marks.

## Files

| File | What it is |
|---|---|
| `main.odin` | window, input, camera, drawing. TODOs 3, 6, 7, 8 |
| `level.odin` | reads `levels/level.ldtk`. TODOs 4, 5 |
| `assets/` | your art goes here: `tiles.png` (and `hero.png` if you want) |
| `levels/` | your LDtk project goes here: `level.ldtk` |
| `MEMO.md` | the memo and AI disclosure you fill in |
| `ATTRIBUTION.md` | every asset you did **not** make (probably none) |

## Run

Unzip `ldtk-level.zip`, then from inside the `ldtk-level` folder:

```sh
odin run .
```

`WASD` / arrows move · `F1` debug view (walls outlined, your collision box) ·
`F5` read the level again from disk (edit in LDtk, save, press F5).

It runs before you do anything: a blue square on an empty screen and a "No
level yet" message. Every TODO below adds something you can **see**.

---

## Part A — draw a tileset (TODO 1)

A **tileset** is one PNG cut into equal squares. Yours has **16×16** tiles.

1. In [Pixelorama](https://pixelorama.org) (or LibreSprite / Piskel), make a new
   image **64 wide × 32 high**. That is 4 columns × 2 rows = room for 8 tiles.
2. Turn on a 16×16 grid so you can see the cells.
3. Draw **at least 4 different tiles**, each filling one whole 16×16 cell:
   - two kinds of **floor** (grass and path, wood and stone, ...)
   - one **wall** (a rock, a bush, a brick, water)
   - one **decoration** (a flower, a crack, a sign)
4. Export as **`assets/tiles.png`**. Save the editable project too
   (`assets/tiles.pxo`): that is your **authoring** file, the PNG is what the
   game reads.

```text
assets/tiles.png   64 x 32
+-------+-------+-------+-------+
| floor | floor | wall  | decor |     each cell is 16 x 16
+-------+-------+-------+-------+
|       |       |       |       |     (empty cells are fine)
+-------+-------+-------+-------+
```

Optional: copy the `hero.png` you drew for `sprite-hero` into `assets/`.

## Part B — paint a level in LDtk (TODO 2)

Install [LDtk](https://ldtk.io) (free, no account).

**B1. Project.** New project, saved as **`levels/level.ldtk`** inside this
folder. In the project settings set the default **grid size to 16**, and leave
"save levels to separate files" **off**.

**B2. Tileset.** In the Tilesets panel add a tileset, choose
`assets/tiles.png`, grid size **16**. LDtk remembers the picture by a path
*relative to the project file*, so keep both inside this folder.

**B3. Layers.** In the Layers panel create exactly these three. The **names
matter**: the code looks for them, spelled exactly like this.

| Name | Type | Settings |
|---|---|---|
| `Entities` | Entities | - |
| `Ground` | Tiles | uses your tileset |
| `Walls` | IntGrid | one value: **1**, named `wall` |

`Entities` on top, `Walls` at the bottom.

**B4. Entities.** In the Entities panel create two, 16×16 each:
`PlayerStart` and `Coin`.

**B5. Level size.** Make the level at least **30 × 20 cells** (480 × 320
pixels), so it is bigger than the screen and the camera has to follow you.

**B6. Paint.**

- On `Ground`: cover the level with your tiles. Left-click paints, right-click
  erases.
- On `Walls`: paint **1** on every cell the player must not enter. Surround the
  level with walls. The picture and the walls are two separate decisions: a
  cell is a wall because you marked it on `Walls`, not because of what it looks
  like.
- On `Entities`: place **one** `PlayerStart` and **at least 5** `Coin`, on
  cells that are not walls.

**B7. Save** (Ctrl+S). Open `levels/level.ldtk` in a text editor once and find
your layer names in it: it is plain JSON.

## Part C — make the game read it (TODOs 3-8)

Do them in order. Run the game after each one.

| TODO | File | What you do | What you should see |
|:--:|---|---|---|
| 3 | `main.odin` | load `tiles.png` once, before the loop | nothing new yet, and no `WARNING` about `tiles.png` in the terminal |
| 4 | `level.odin` | turn the `Walls` numbers into `lv.solid` | press **F1**: every wall cell has a red outline |
| 5 | `level.odin` | read `PlayerStart` and every `Coin` | the square starts where you put it; a gold circle on every coin |
| 6 | `main.odin` | draw every tile | **your level, on screen** |
| 7 | `main.odin` | stop at walls | you slide along walls instead of walking through |
| 8 | `main.odin` | take coins | the counter in the corner goes up |

Then check the pipeline really works: with the game running, move a wall in
LDtk, save, press **F5**. The level changes without restarting.

The reading and parsing of the file (steps 1 and 2 inside `load_level`) is
already written. Read it: it is two library calls.

## Part D — one thing of your own (TODO 9)

Add **one new thing to the level that the starter does not know about**, and
make the code read it from the file. Pick one:

- a **second IntGrid value** on `Walls` (2 = water, mud, spikes, ice...) that
  does something you can see or feel in the game
- a **new entity** (`Exit`, `Enemy`, `Key`, `Sign`...) that the game reads and
  does something with
- a **second Tiles layer** drawn *over* the player (treetops, a roof, a bridge)

Whatever you choose, the rule is the same: it is **placed in LDtk**, not typed
in the code, and it still works after you move it and press F5.

## Part E — the memo

Fill in `MEMO.md`: half a page to one page, in your own words, plus the AI
disclosure. The questions are in the file.

---

## Hand in

On Canvas, by **Sun Oct 18, 23:59**: a **ZIP of your whole `ldtk-level`
folder**. The folder must contain:

- `assets/tiles.png` **and** its editable source (`tiles.pxo`, `.aseprite`, `.piskel`...)
- `levels/level.ldtk`
- `main.odin`, `level.odin` with the TODOs done
- `MEMO.md` filled in, `ATTRIBUTION.md` (say "all art is mine" if it is)

Individual work. LLM assistants are allowed for the code under the usual
conditions: disclose it, and be able to explain any line. The art and the level
are yours, made by hand in the tools: that is the point of the quest.

Late policy is the course's: 10% of the value per day or part-day, up to 72
hours.

## How the 5 points are awarded

| | What we look for | pts |
|---|---|:--:|
| **A. Tileset** | `tiles.png` drawn by you, 16×16 cells, at least 4 different tiles, editable source included. Quality is not graded | 0.5 |
| **B. Level** | `level.ldtk` with the three layers named as asked, at least 30×20 cells, one `PlayerStart`, at least 5 `Coin`, walls that make sense with the picture | 1.0 |
| **C. Import** | the game draws your level from the file, starts at `PlayerStart`, stops at walls, collects coins; textures loaded once; **F5 works**; no tile, wall or coin position in the code | 1.5 |
| **D. Your own addition** | one new thing placed in LDtk, read by the code, and still working after you move it | 0.5 |
| **E. Memo + AI disclosure** | every question answered, specific, in your own words | 1.5 |
| | **Total** | **5.0** |

## If something is wrong

| Symptom | Cause |
|---|---|
| "No level yet" stays on screen | the file is not at `levels/level.ldtk`, or it is not saved; the terminal says which |
| Tiles look sliced, showing half of two tiles | a grid size is not 16: check the project, the tileset and the layer in LDtk, and your PNG |
| The map is blank inside LDtk | `tiles.png` was moved or renamed after you added it; LDtk stores a relative path |
| Level is invisible in the game, no error | the texture did not load: look for a `WARNING` about `tiles.png` in the terminal |
| F1 shows no red outlines | the IntGrid layer is not named exactly `Walls`, or you painted a value other than 1, or TODO 4 is not done |
| The square starts in the top-left corner | the entity is not named exactly `PlayerStart`, or TODO 5 is not done |
| The square cannot move at all | it starts inside a wall: move `PlayerStart` to a free cell |
| Only part of the level loads | "save levels to separate files" is on: turn it off and save again |
| Thin lines between tiles while moving | `ZOOM` is not a whole number |
