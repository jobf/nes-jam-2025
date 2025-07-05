# What

Here lies the code I used to submit a game to NES Jam 2025 on itch.io

The game can really only be considered a prototype in it's current state, although it is full playable to the end.

It was an excuse for me to build a mini-engine which can emulate the graphical style of the NES/famicom console.

Features of this graphically are...

- all graphics are formed of 8x8 tiles
- tiles can be coloured using a range of 8 palettes
- each palette has 3 colors and transparent
- backgrounds are fixed grids of tiles
- backgrounds are coloured in 4x4 tile regions

I didn't finish all the features but it's still being worked on. Some of the todo list is...

- sprites are formed from a finite pool of 64 tiles
- animate background tiles
- level chunking
- camera scrolling
- sound effects
- background music (multi channel?)

# How to run

## Install prerequisites

You need lime (haxe cross target application toolchain) -> https://lime.openfl.org/docs/home/

Then you need the libraries.

```
haxelib install peote-view
haxelib install input2action
haxelib install deepnightLibs
haxelib install ldtk-haxe-api
```

## Run

Then you can run it.

```
lime test hl
```

## Debug

If you build with the `-debug` flag then you can preview the palette changes, check the tilemap collisions and log arbitrary information at run time.

Press F2 key at run time to toggle the tile/data debugging.

```
lime test hl -debug
```

You can also use a browser debugger to step through the hx source with the web build (e.g. check Sources tabin chromium DevTools).

```
lime test html5 -debug
```

## Release

The release is html5 (for distribution on itch).

There is a script `build-release.sh` for bundling the final html5 build into a zip. This script needs [ldtk-crush](https://github.com/jobf/ldtk-crush) to be installed.

# Level data

The level data is stored in `assets/levels.ldtk`. This is editable using [LDtk editor](https://ldtk.io/).

Each level consists of the following layers.

- tiles (the layout of the grpahical tiles on the level)
- entities (e.g. Player entity)
- palette (which palette to color 4x4 regions of the level)
- front (should the level tiles be rendered in front of the entity sprites)

Each layer can have it's own palettes selected.

## Hot reload

If you're running the hashlink target then the code will be "watching" the ldtk file in assets folder for changes.

So you can edit a level in ldtk and then save the file and the game will reload the new data. It will also reload images at the same time, so you can change these on the fly too.

## Config level

This is level_0 and is used for configuration only.

## Animations level

This is currently level_5 and is used to configure animations.

In the future I'll make a template where this is level_1, this feature came late on so I just the first level I didn't mind overwriting.