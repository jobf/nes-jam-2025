# What

Here lies the code I used to submit a game to NES Jam 2025 on itch.io

The game can really only be considered a prototype in it's current state, although it is full playable to the end.

It was an excuse for me to build a mini-engine which can emulate the graphical style of the NES/famicom console.

Features of this graphically are...

- all graphics are formed of 8x8 tiles
- tiles can be coloured using a range of 8 palettes
- each palette has 3 colors and transparent
- backgrounds are fixed grids of tiles

I didn't finish all the features but it's still being worked on. Some of the todo list is...

- sprites are formed from a finite pool of 64 tiles
- animate background tiles
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
