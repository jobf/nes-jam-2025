package kiss.graphics;

import nes.Tiles.TileSetter;
import nes.Nametable;

using kiss.util.Math;

@:publicFields
class AnimateTile
{
	var data:Map<String, TileConfig>;
	var now_playing:TileConfig;
	var change_frame:(tile_index:Int) -> Void;
	var position:Int;
	private var frames_remaining:Int;
	var is_animation_ended:Bool = true;
	var now_playing_name:String;

	function new(data:Map<String, TileConfig>, change_frame:(tile_index:Int) -> Void)
	{
		this.data = data;
		this.change_frame = change_frame;
	}

	function play_animation(name:String):Void
	{
		if (now_playing_name != name && data.exists(name))
		{
			now_playing_name = name;
			now_playing = data[name];
			frames_remaining = now_playing.frame_rate;
			position = 0;
			change_frame(now_playing.frames[position]);
			is_animation_ended = false;
			is_playing = true;
		}
	}

	var is_playing:Bool = false;

	function step()
	{
		if (is_playing)
		{
			switch now_playing.mode
			{
				case LOOP_STEPPED:
					position = (position + 1).wrap(now_playing.frames.length);
					change_frame(now_playing.frames[position]);
				case LOOP_TIMED:
					frames_remaining--;
					if (frames_remaining < 0)
					{
						frames_remaining = now_playing.frame_rate;
						position = (position + 1).wrap(now_playing.frames.length);
						change_frame(now_playing.frames[position]);
					}
				case ONCE_TIMED:
					frames_remaining--;
					if (frames_remaining < 0)
					{
						frames_remaining = now_playing.frame_rate;
						position = (position + 1).wrap(now_playing.frames.length);
						if (position == now_playing.frames.length - 1)
						{
							is_playing = false;
							is_animation_ended = true;
						}
						else
						{
							change_frame(now_playing.frames[position]);
						}
					}
				case ONCE_STEPPED:
					position = (position + 1).wrap(now_playing.frames.length);
					if (position == now_playing.frames.length - 1)
					{
						is_playing = false;
						is_animation_ended = true;
					}
					else
					{
						change_frame(now_playing.frames[position]);
					}
				case FRAME:
					// do nothing, it's already set the frame
					return;
			}
		}
	}
}

@:publicFields
@:structInit
class TileConfig
{
	var mode:AnimationMode = LOOP_TIMED;
	var frames:Array<Int>;
	var frame_rate:Int;
}

@:publicFields
class AnimateMosaic
{
	var data:Map<String, MosaicConfig>;
	var now_playing:MosaicConfig;
	var change_tile:(col:Int, row:Int, tile:Int, isFlipped:Bool) -> Void;
	var position:Int;
	private var frames_remaining:Int;
	var is_animation_ended:Bool = true;
	var now_playing_name:String;
	var column:Int;
	var row:Int;
	var isFlipped(default, set):Bool;

	function new(data:Map<String, MosaicConfig>, change_tile:(col:Int, row:Int, tile:Int, isFlipped:Bool) -> Void, column:Int, row:Int)
	{
		this.data = data;
		this.change_tile = change_tile;
		this.column = column;
		this.row = row;
		var anims = [for (k in data.keys()) k];
		play_animation(anims[0]);
	}

	function play_animation(name:String):Void
	{
		if (now_playing_name != name && data.exists(name))
		{
			now_playing_name = name;
			now_playing = data[name];
			frames_remaining = now_playing.frame_rate;
			position = 0;
			change_frame();
			is_animation_ended = false;
			is_playing = true;
		}
	}

	function change_frame()
	{
		var tiles = now_playing.frames[position];
		var cols = now_playing.frame_columns;
		var colOffset = isFlipped ? cols - 1 : 0;
		
		for (n in 0...tiles.length)
		{
			var r = row + cols.row(n);
			var c = column + colOffset;
			change_tile(c, r, tiles[n], isFlipped);
			var direction = isFlipped ? -1 : 1;
			colOffset = (colOffset + direction).wrap(cols);
		}
	}

	var is_playing:Bool = false;

	function step()
	{
		if (is_playing)
		{
			switch now_playing.mode
			{
				case LOOP_STEPPED:
					position = (position + 1).wrap(now_playing.frames.length);
					change_frame();
				case LOOP_TIMED:
					frames_remaining--;
					if (frames_remaining < 0)
					{
						frames_remaining = now_playing.frame_rate;
						position = (position + 1).wrap(now_playing.frames.length);
						change_frame();
					}
				case ONCE_TIMED:
					frames_remaining--;
					if (frames_remaining < 0)
					{
						frames_remaining = now_playing.frame_rate;
						position = (position + 1).wrap(now_playing.frames.length);
						if (position == now_playing.frames.length - 1)
						{
							is_playing = false;
							is_animation_ended = true;
						}
						else
						{
							change_frame();
						}
					}
				case ONCE_STEPPED:
					position = (position + 1).wrap(now_playing.frames.length);
					change_frame();
					if (position == now_playing.frames.length - 1)
					{
						is_playing = false;
						is_animation_ended = true;
					}
				case FRAME:
					// do nothing, it's already set the frame
					return;
			}
		}
	}

	function set_isFlipped(value:Bool):Bool
	{
		isFlipped = value;
		change_frame();
		return isFlipped;
	}
}

@:publicFields
@:structInit
class MosaicConfig
{
	var mode:AnimationMode = LOOP_TIMED;
	var frames:Array<Array<Int>>;
	var frame_rate:Int = 1;
	var frame_columns:Int = 1;
}

enum AnimationMode
{
	LOOP_STEPPED;
	LOOP_TIMED;
	ONCE_STEPPED;
	ONCE_TIMED;
	FRAME;
}
