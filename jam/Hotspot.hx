import nes.Tiles;
import kiss.util.Rectangle;
import LdtkData.Enum_HotspotStyle;

class Hotspot
{
	public var footprint:Rectangle;

	public var sprite:Sprite;
	var stages:Int = 3;
	public var tileStart:Int = 32;
	var tileEnd:Int = 35;
	var switchTileStart:Int = 56;
	var switchTileEnd:Int = 57;

	public var isLocked:Bool = true;
	public var isEnabled:Bool = true;
	public var isActive:Bool = false;

	var step:Float;
	var stepRemaining:Float;
	var onUnlock:() -> Void;
	public var style:Enum_HotspotStyle;

	public function new(footprint:Rectangle, sprite:Sprite, duration:Int, style:Enum_HotspotStyle, onUnlock:() -> Void = null)
	{
		this.style = style;
		this.footprint = footprint;
		this.sprite = sprite;
		initSprite();
		this.onUnlock = onUnlock;
		step = Std.int(duration / stages);
		stepRemaining = step;
	}

	function initSprite()
	{

		// todo; these use background palettes so should be tiles (not Sprites)
		// therefore we need to implement a way of doing animations on the tiles (change certain indexes)
		// maybe do this after adding the ldtk entity editor?
		switch style
		{
			case FROG:
				tileStart = 32;
				tileEnd = 35;
				sprite.tileB.changeBgPalette(2);
				sprite.tileF.changeBgPalette(2);
			case TUTOR:
				tileStart = 32;
				tileEnd = 35;
				sprite.changeTile(TileSetter.EmptySpriteId);
				sprite.tileB.changeBgPalette(2);
				sprite.tileF.changeBgPalette(2);
				isEnabled = false;
			case UNBLOCK:
				tileStart = 56;
				tileEnd = 57;
			case SOAP:
				sprite.tileB.isFlippedX = true;
				sprite.tileF.isFlippedX = true;
				tileStart = 80;
				tileEnd = 81;
				sprite.tileB.changeBgPalette(3);
				sprite.tileF.changeBgPalette(3);
			case BUBBLE:
				tileStart = 52;
				tileEnd = 52;
				sprite.tileB.changeBgPalette(0);
				sprite.tileF.changeBgPalette(0);
		}
		if (style != TUTOR)
		{
			sprite.changeTile(tileStart);
		}
		sprite.move(footprint.center_x, footprint.center_y);
	}

	public function update()
	{
		if (isActive)
		{
			stepRemaining--;
			var tileId = sprite.tileF.tile;
			if (stepRemaining <= 0 && tileId < tileEnd)
			{
				tileId++;
				sprite.changeTile(tileId);
				stepRemaining = step;
			}
			if (tileId >= tileEnd && isLocked)
			{
				isLocked = false;
				if (style == BUBBLE)
				{
					sprite.changeTile(TileSetter.EmptySpriteId);
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
		if(!isEnabled) return false;

		var isOverlap = footprint.isOverlap(x, y);
		if (isLocked)
		{
			isActive = isOverlap;
		}
		return isOverlap;
	}
}
