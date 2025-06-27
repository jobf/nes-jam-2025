package kiss.graphics;

using kiss.util.Math.ValueExtensions;

@:publicFields
class AnimateTile
{
	var data:Map<String, AnimationConfig>;
	var now_playing:AnimationConfig;
	var change_frame:(tile_index:Int) -> Void;
	var position:Int;
	private var frames_remaining:Int;
	var is_animation_ended:Bool = true;
	var now_playing_name:String;

	function new(data:Map<String, AnimationConfig>, change_frame:(tile_index:Int) -> Void)
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
class AnimationConfig
{
	var mode:AnimationMode = LOOP_TIMED;
	var frames:Array<Int>;
	var frame_rate:Int;
}

enum AnimationMode
{
	LOOP_STEPPED;
	LOOP_TIMED;
	ONCE_STEPPED;
	ONCE_TIMED;
	FRAME;
}
