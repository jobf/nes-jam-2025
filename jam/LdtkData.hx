import kiss.graphics.AnimateTile;
import ldtk.Json;
import ldtk.*;
import nes.Nametable;

/** 
 * Generates typed data from LDtk level file, see https://ldtk.io/docs/game-dev/haxe-in-game-api/usage/ 
 */
#if final
private typedef _Tmp = haxe.macro.MacroType<[ldtk.Project.build("jam/assets-final/levels.ldtk")]>;
#else
private typedef _Tmp = haxe.macro.MacroType<[ldtk.Project.build("jam/assets/levels.ldtk")]>;
#end

/**
 * Loads the LdtkData and watches the file for changes.
 * Also support for reloading image data.
 */
@:publicFields
class HotReload
{
	var root:String;
	var ldtk_path:String;
	var on_reload:() -> Void;
	var file_time:Date;
	var ldtk_data:LdtkData;

	function new(root:String, ldtk:String, on_reload:() -> Void)
	{
		this.root = root;
		this.on_reload = on_reload;
		ldtk_path = haxe.io.Path.join([root, ldtk]);
		#if hotreload
		#if windows
		var path_segments = haxe.io.Path.normalize(ldtk_path).split("/");
		ldtk_path = haxe.io.Path.join(path_segments.slice(path_segments.length - 2));
		#end
		readFile();
		trace(sys.FileSystem.readDirectory(root));
		trace(ldtk_path);
		file_time = sys.FileSystem.stat(ldtk_path).mtime;
		#else
		ldtk_data = new LdtkData();
		#end
	}

	#if hotreload
	function readFile():Void
	{
		var json = sys.io.File.getContent(ldtk_path);
		ldtk_data = new LdtkData(json);
	}
	#end

	function update()
	{
		#if hotreload
		var next_file_time = sys.FileSystem.stat(ldtk_path).mtime;
		if (next_file_time.getTime() > file_time.getTime())
		{
			file_time = next_file_time;
			readFile();
			on_reload();
		}
		#end
	}

	public function load_image(asset_path:String):lime.graphics.Image
	{
		#if hotreload
		var path = asset_path;
		#if linux
		path = haxe.io.Path.join([root, path]);
		#end
		trace('loading image from file $path');
		return lime.graphics.Image.fromFile(path);
		#end
		trace('loading embedded $asset_path');
		return lime.utils.Assets.getImage(asset_path);
	}
}

// remainder of this file contains functions for pulling the ldtk data into more efficient structures for use at run time
// ----------------------------------------------------------------------------------------------------------------------

function readCollisionsCoarse(collisionType:Layer_IntGrid):Array<Int>
{
	var collision:Array<Int> = [];
	for (cy in 0...collisionType.cHei)
	{
		for (cx in 0...collisionType.cWid)
		{
			var tileId = 0;
			var front = 0;

			if (collisionType.hasValue(cx, cy))
			{
				tileId = collisionType.getInt(cx, cy);
			}

			collision.push(tileId);
		}
	}

	return collision;
}

function readAttributes(layer:Layer_IntGrid):Array<Int>
{
	var attributes:Array<Int> = [];
	for (cy in 0...layer.cHei)
	{
		for (cx in 0...layer.cWid)
		{
			if (layer.hasValue(cx, cy))
			{
				attributes.push(layer.getInt(cx, cy));
			}
			else
			{
				attributes.push(0);
			}
		}
	}

	return attributes;
}

function readLevel(layer:Layer_Tiles, fgMask:Layer_IntGrid):Array<TileIndex>
{
	var tiles = [];

	for (cy in 0...layer.cHei)
	{
		for (cx in 0...layer.cWid)
		{
			var tileId = 0;
			var front = 0;

			if (layer.hasAnyTileAt(cx, cy))
			{
				var stack = layer.getTileStackAt(cx, cy);
				tileId = stack[stack.length - 1].tileId;
			}

			if (fgMask.hasValue(cx, cy))
			{
				front = fgMask.getInt(cx, cy);
			}

			tiles.push(new TileIndex(front, tileId));
		}
	}

	return tiles;
}

function convertToTileId(infos:Null<TilesetRect>, cellSize:Int = 8, tilesInRow:Int = 16):Int
{
	var c = Std.int(infos.x / cellSize);
	var r = Std.int(infos.y / cellSize);
	return kiss.util.Math.Grid2d.index(tilesInRow, c, r);
}

function read_animations(definitions:Array<LdtkData.Entity_Animation>, tiles:ldtk.Layer_Tiles):Map<String, MosaicConfig>
{
	var animations:Map<String, MosaicConfig> = [];
	for (animation in definitions)
	{
		var frames:Array<Array<Int>> = [];
		var frameCount = Std.int(animation.width / animation.f_FrameWidth);
		var frameColumns = Std.int(animation.f_FrameWidth / 8);
		var frameRows = Std.int(animation.f_FrameHeight / 8);

		for (n in 0...frameCount)
		{
			var frameTiles:Array<Int> = [];
			var left = n * frameColumns;
			var right = left + frameColumns;
			for (r in 0...frameRows)
			{
				for (c in left...right)
				{
					var col = c + animation.cx;
					var row = r + animation.cy;
					var tile:Int = 0;
					if (tiles.hasAnyTileAt(col, row))
					{
						var stack = tiles.getTileStackAt(col, row);
						tile = stack[stack.length - 1].tileId;
					}
					frameTiles.push(tile);
				}
			}
			frames.push(frameTiles);
		}

		animations.set(animation.f_Name, {
			mode: ONCE_STEPPED,
			frames: frames,
			frame_columns: Std.int(animation.f_FrameWidth / tiles.gridSize)
		});
		
	}
	return animations;
}
