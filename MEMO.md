# SQ1 memo — the level pipeline

Half a page to one page in total, in your own words. Be specific: file names,
layer names, the actual mistake you made.

## 1. Authoring and runtime

In your own project folder, which files are **authoring** files and which does
the **game** read? Name them. What would you lose if you deleted each kind?

My authoring files are "tiles.pxo" which I created using Pixelorama, and "level.ldtk" created in LDTK. The files that are read by the code are "tiles.png", "hero.png", and "level.ldtk". If I were to lose the png files, I would be able to generate them again easily from the authoring files. If I were to lose the authoring files that those files are generated from, I would have to edit the pngs directly instead of having the extra context available to Pixelorama that the .pxo files contain. If I lost "level.ldtk", the game would not be able to function without the information of that file, and I would be unable to modify the contents without entirely recreating that file. 

## 2. A promise you broke

The editor and the code agree on a few things: a grid size, layer names, entity
names, a file path. Describe **one** time something did not show up or looked
wrong while you worked. What did you see, what was the cause, and how did you
find it?

When I was trying to add flowers as an entity, they were initially not being picked up in the correct spots. This is because I had started workign by adapting the code for the coins. The coins were a different size, and also picked up from a distance different from what's appropriate for the flowers. I fixed this by playing with the pickup distance and center position until the interaction appeared correct. 

## 3. Looks and meaning

Give one cell of your level where the picture (`Ground`) and the rule (`Walls`)
say different things on purpose, or explain why you have none. What would go
wrong if the game decided "is this a wall?" by looking at which tile is drawn?

My game has no tiles that are registered as walls but don't appear to be. If the game decided something was a wall by looking at what tile was drawn, the code would become more complex when you have multiple different textures that appear as walls. Additionally, you lose the convenience of making anything impassible separate of what's drawn on that tile which might be used to make it so you can't walk through a person or other object on a map that isn't necessarily a wall. 

## 4. Your own addition

What did you add in Part D? How do you know the code reads it from the file
(what happens when you move it in LDtk and press F5)?

In part D, I added a flower that can be picked up adding to a new count for the flowers you've picked up that appear next to you're coin count. I know the code reads it from the files because I implemented it following similar methods to the other entities that loaded from the files like the hero and coin entities. When I move, add, or remove a flower to the ldtk file and then press F5, the new flower positions are reflected. 

## 5. Your Main Quest

Will your own game use LDtk, another editor, or no editor? Why? What would live
in the level file, and what would stay in code?

As of right now, I don't think that I will use LDtk for my main quest. This is because my game isn't designed around a player being able to freely walk around a stage. However I was thinking about adding a state where a player can move through a limited area inbetween existing states planned for my game, however I will likely only add this if I have extra time to add these areas. For these areas, most things would remain in the level file while information about what the player interacts with or chooses when moving out of these states will be retained by the code. 

## AI disclosure

Which tools did you use (if any), and for what? "None" is a valid answer.
Disclosure is never penalized.

| tool / model | what you used it for |
|---|---|
| Copilot / GPT-6 Luna | Syntax debugging |
