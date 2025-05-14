# Development

ⓘ See https://github.com/bmaupin/civ-modding-tools/blob/main/civilization-beyond-earth/docs/development.md

#### Reload mod changes

Unfortunately [the trick from Micro Beyond Earth](https://github.com/bmaupin/micro-beyond-earth/blob/main/docs/development.md) doesn't work to reload the mod without exiting the game. Maybe the mod is too big or contains too many files?

What does work is go into the _DLC_ menu and unload and reload one of the DLC.

⚠️ Make sure if you're loading a save game to test the mod that you have the same DLC loaded that the save was created with, otherwise Beyond Earth will crash as per https://github.com/bmaupin/civ-be-linux-fixes/?tab=readme-ov-file#the-game-crashes-loading-a-saved-game-with-mods-and-different-dlc

#### Publish to Steam workshop

ⓘ See https://github.com/bmaupin/civ-modding-tools/blob/main/civilization-beyond-earth/docs/publishing.md

Sample command for publishing a new version of the mod:

```
steamremotestorage-uploader -a 65980 -i 3478662712 -f "eclipse (v 2).civbemod" -n "v2: Version summary"
```
