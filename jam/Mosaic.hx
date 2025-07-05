import nes.Tiles;
import nes.Nametable;
import kiss.util.Rectangle;

using kiss.util.Math;

class Mosaic
{
	public var footprint:Rectangle;
	var cols:Int;
	var rows:Int;
	var tileSize:Int;
	var tiles:Array<TileIndex>;
	public var paletteIndex:Int= 0;

	static var defaultTile:Int = 4; // yucky.. do we need to build this

	public var isFlipped:Bool = false;

	public function new(footprint:Rectangle, tileSize:Int = 8, defaultTile:Int = 4)
	{
		this.footprint = footprint;
		this.tileSize = tileSize;
		cols = Std.int(footprint.width / tileSize);
		rows = Std.int(footprint.height / tileSize);
		tiles = [for (n in 0...cols * rows) defaultTile ?? Mosaic.defaultTile];
	}

	public function arrange(tiles:Array<TileIndex>)
	{
		for (n in 0...tiles.length)
		{
			this.tiles[n] = tiles[n];
		}
	}

	public function drawToLevel(setLevelTile:(col:Int, row:Int, tileIndex:TileIndex, isFlipped:Bool, paletteIndex:Int) -> Void)
	{
		var column = Std.int(footprint.left / tileSize);
		var row = Std.int(footprint.top / tileSize);

		var colOffset = isFlipped ? cols - 1 : 0;
		for (n in 0...tiles.length)
		{
			var r = row + cols.row(n);
			var c = column + colOffset;
			setLevelTile(c, r, tiles[n], isFlipped, paletteIndex);
			var direction = isFlipped ? -1 : 1;
			colOffset = (colOffset + direction).wrap(cols);
		}
	}

	public function drawFree(setFreeTile:(x:Int, y:Int, tileIndex:TileIndex, isFlipped:Bool, paletteIndex:Int) -> Void)
	{
		var column = 0;
		var row = 0;

		var colOffset = isFlipped ? cols - 1 : 0;
		for (n in 0...tiles.length)
		{
			var r = row + cols.row(n);
			var c = column + colOffset;
			var x = Std.int(footprint.x + (c * tileSize));
			var y = Std.int(footprint.y + (r * tileSize));
			setFreeTile(x, y, tiles[n], isFlipped, paletteIndex);
			var direction = isFlipped ? -1 : 1;
			colOffset = (colOffset + direction).wrap(cols);
		}
	}

	public function clear() {
		for (i in 0...tiles.length) {
			tiles[i] = 0;
		}
	}
}
