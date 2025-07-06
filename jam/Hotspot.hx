import kiss.util.Repeat.Countdown;
import kiss.graphics.AnimateTile;
import kiss.util.Rectangle;
import LdtkData.Enum_HotspotStyle;
import nes.Tiles;

class Hotspot
{
	// public var footprint:Rectangle;
	var stages:Int = 3;

	public var tileStart:Int = 32;

	var tileEnd:Int = 35;
	var switchTileStart:Int = 56;
	var switchTileEnd:Int = 57;

	public var isLocked:Bool = true;
	public var isEnabled:Bool = true;
	public var isActive:Bool = false;

	var animateCountdown:Countdown;

	var onUnlock:() -> Void;

	public var style:Enum_HotspotStyle;

	var animations:Map<String, MosaicConfig>;

	public var animation:AnimateMosaic;
	public var mosaic:Mosaic;

	public function new(mosaic:Mosaic, animations:Map<String, MosaicConfig>, duration:Int, style:Enum_HotspotStyle, onUnlock:() -> Void = null)
	{
		// this.footprint = footprint;
		// this.animation = animation;
		this.mosaic = mosaic;
		animation = new AnimateMosaic(animations, mosaic);
		// super(animations, col, row, width, height, cell_size);
		this.style = style;
		this.onUnlock = onUnlock;
		animateCountdown = new Countdown(Std.int(duration / stages));
	}

	public function update()
	{
		if (isActive)
		{
			animateCountdown.remaining--;
			if (animateCountdown.remaining <= 0 && !animation.is_animation_ended)
			{
				animation.step();
				animateCountdown.reset();
			}

			if (isLocked && animation.is_animation_ended)
			{
				if (style == BUBBLE)
				{
					// todo - hide
					// sprite.changeTile(TileSetter.EmptySpriteId);
				}
				if (onUnlock != null)
				{
					onUnlock();
				}
			}
		}
	}

	public function overlap(x:Float, y:Float):Bool
	{
		if (!isEnabled)
			return false;

		var isOverlap = mosaic.footprint.isOverlap(x, y);
		if (isLocked)
		{
			isActive = isOverlap;
		}
		return isOverlap;
	}

	public function showInitialFrame()
	{
		animation.step();
	}
}
