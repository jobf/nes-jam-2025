package kiss.graphics;

using kiss.util.Math.ValueExtensions;
using kiss.util.Math.Grid2d;

@:publicFields
class AnimateScenery
{
	var data:Map<String, AnimationConfig>;
	var now_playing:AnimationConfig;
	var change_tile:(col:Int, row:Int, tile:Int) -> Void;
	var position:Int;
	private var frames_remaining:Int;
	var is_animation_ended:Bool = true;
	var now_playing_name:String;
	var column:Int;
	var row:Int;

	function new(data:Map<String, AnimationConfig>, change_tile:(col:Int, row:Int, tile:Int) -> Void, column:Int, row:Int)
	{
		this.data = data;
		this.change_tile = change_tile;
		this.column = column;
		this.row = row;
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

	function change_frame() {
		trace(now_playing.frames[position]);
		for (i => tile in now_playing.frames[position]) {
			// var col = ;
			// var row = row;
			change_tile(column + now_playing.frame_width.column(i), row + now_playing.frame_width.row(i), tile);
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
					if (position == now_playing.frames.length - 1)
					{
						is_playing = false;
						is_animation_ended = true;
					}
					else
					{
						change_frame();
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
class AnimationConfig
{
	var mode:AnimationMode = LOOP_TIMED;
	var frames:Array<Array<Int>>;
	var frame_rate:Int;
	var frame_width:Int = 1;
}

enum AnimationMode
{
	LOOP_STEPPED;
	LOOP_TIMED;
	ONCE_STEPPED;
	ONCE_TIMED;
	FRAME;
}
