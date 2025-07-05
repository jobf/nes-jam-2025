import haxe.ds.Vector;
import kiss.graphics.Palette;
import kiss.graphics.PeoteView;
import kiss.util.Cycle;
import lime.app.Application;
import lime.utils.Assets;
import nes.Nametable.TileIndex;
import nes.Palette;
import nes.Tiles;
import peote.view.Display;
import peote.view.Texture;

class TileCycle extends Cycle<Tile>
{
	public function new(buffer:TileBuffer, size:Int)
	{
		super(Vector.fromArrayCopy([
			for (n in 0...size)
				buffer.addElement(new Tile())
		]));
	}

	public function clear()
	{
		for (tile in items) {
			tile.tile = 0;
		}
	}

	public function setTile(x:Int, y:Int, tileIndex:TileIndex, isFlipped:Bool):Void{
		var tile = get();
		tile.tile = tileIndex.index();
		tile.isFlippedX = isFlipped;
		tile.x = x;
		tile.y = y;
	}
}

class TestSprites extends Application
{
	override function onPreloadComplete()
	{
		var peoteView = new PeoteView(window);
		peoteView.zoom = 4;

		var uncoloredDisplay = new Display(0, 0, window.width, window.height, 0x401040ff);
		peoteView.addDisplay(uncoloredDisplay);

		var palettes = new Palette(lospec_palette);

		var tileSize = 8;

		var image = Assets.getImage("assets/tiles.png");
		var tex = Texture.fromData(image);
		tex.tilesX = Std.int(image.width / tileSize);
		tex.tilesY = Std.int(image.height / tileSize);

		var buffer = new TileBuffer(64, tex, palettes);
		buffer.addToDisplay(uncoloredDisplay);

		var cycle = new TileCycle(buffer, 64);
		var sprites:Array<Mosaic> = [];

		var sprite = new Mosaic({
			x: 0,
			y: 0,
			width: 16,
			height: 16
		});

		sprite.arrange([
			 64, 65,
			128, 129
		]);
		sprites.push(sprite);

		onUpdate.add(i ->
		{
			// set all sprite tiles to empty
			cycle.clear();

			// draw sprites using tiles from the cycle
			for (mosaic in sprites) {
				mosaic.drawFree(cycle.setTile);
			}

			// update gpu
			buffer.update();
		});

		window.onMouseMove.add((x, y) ->
		{
			sprite.footprint.x = (x  / peoteView.zoom) - sprite.footprint.width / 2;
			sprite.footprint.y = (y  / peoteView.zoom) - sprite.footprint.height / 2;
		});

		// window.onKeyDown.add((code, modifier) -> switch code
		// {
		// 	case NUMBER_0:
		// 	case NUMBER_1:
		// 	case NUMBER_2:
		// 	case NUMBER_3:
		// 	case NUMBER_4:
		// 	case NUMBER_5:
		// 	case NUMBER_6:
		// 	case NUMBER_7:
		// 	case NUMBER_8:
		// 	case NUMBER_9:
		// 	case _: return;
		// });
	}
}
