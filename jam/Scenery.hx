import nes.Nametable;
import kiss.util.Rectangle;

class Scenery
{
	var footprint:Rectangle;
	var cols:Int;
	var rows:Int;
	var tileSize:Int;
	var tiles:Array<TileIndex>;
	static var defaultTile:Int = 4;

	public function new(footprint:Rectangle, tileSize:Int=8, defaultTile:Null<Int>=null)
	{
		this.footprint = footprint;
		this.tileSize = tileSize;
		cols = Std.int(footprint.width / tileSize);
		rows = Std.int(footprint.height / tileSize);
		tiles = [for(n in 0...cols * rows) defaultTile ?? Scenery.defaultTile];
	}

	public function arrange(tiles:Array<TileIndex>)
	{
		for (n in 0...tiles.length)
		{
			this.tiles[n] = tiles[n];
		}
	}

	public function draw(setTile:(col:Int, row:Int, tileIndex:TileIndex, isFlipped:Bool) -> Void)
	{
		var left = Std.int(footprint.left / tileSize);
		var top = Std.int(footprint.top / tileSize);
		var i = 0;
		// trace(tiles);
		for (r in top...top + rows)
		{
			for (c in left...left + cols)
			{
				var isFlipped = false;
				setTile(c, r, tiles[i], isFlipped);
				i++;
			}
		}
	}

	public function flipX(bool:Bool) {
		//todo
	}
}
