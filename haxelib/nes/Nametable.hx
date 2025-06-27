package nes;

/**
 * The first 31 bits of this are the index of the tile on the map
 * The highest bit is which layer the tile is, back or front
 * e.g. Bit 31: Layer, Bits 0-30: Index
 */
abstract TileIndex(Int)
{
	public function new(layer:Int, tile:Int)
	{
		this = pack(layer, tile);
	}

	private inline function pack(layer:Int, tile:Int):Int
	{
		return (layer << 31) | tile;
	}

	inline public function index():Int
	{
		return this & 0x7FFFFFFF; // mask out the highest bit, leaving the tile index bits
	}

	inline public function layer():Int
	{
		return (this >> 31) & 1; // isolate bit 31, the layer flag
	}

	@:from
	static function fromInt(tileIndex:Int):TileIndex
	{
		// we'll default to background layer to keep it simple
		return new TileIndex(0, tileIndex);
	}
}

abstract PaletteIndex(Int)
{
	public function new(value:Int)
	{
		// can only be 0, 1, 2, or 3, so clamp it
		this = (value < 0) ? 0 : (value > 3) ? 3 : value;
	}

	@:from
	static function fromInt(i:Int):PaletteIndex
	{
		return new PaletteIndex(i);
	}
}

class Nametable
{
	public var tiles(default, null):Vector<TileIndex>;
	public var attributes(default, null):Vector<PaletteIndex>;

	public static var tileCols(default, never):Int = 32;
	public static var tileRows(default, never):Int = 30;
	public static var attrCols(default, never):Int = 8;
	public static var attrRows(default, never):Int = 8;

	public function new()
	{
		var tile:TileIndex = 0;
		tiles = new Vector(tileCols * tileRows, tile);

		var palette:PaletteIndex = 0;
		attributes = new Vector(attrCols * attrRows, palette);
	}
}
