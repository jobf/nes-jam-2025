import kiss.util.Rectangle;
import kiss.graphics.Palette;
import kiss.graphics.PeoteView;
import lime.app.Application;
import lime.utils.Assets;
import nes.Palette;
import nes.Tiles;
import peote.view.Display;
import peote.view.Texture;

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

		var mosaic = new Mosaic({
			x: 0,
			y: 0,
			width: 16,
			height: 16
		});

		mosaic.arrange([
			 64, 65,
			128, 129
		]);

		var sprite = new Sprite({
			x: 0,
			y: 0,
			width: 16,
			height: 16
		});

		sprite.arrange([
			 64, 65,
			128, 129
		]);

		var sprites = [sprite];

		onUpdate.add(i ->
		{
			// set all sprite tiles to empty
			cycle.clear();

			mosaic.drawFree(cycle.setTile);

			// draw sprites using tiles from the cycle
			for (sprite in sprites)
			{
				sprite.drawFree(cycle.setTile);
			}

			// update gpu
			buffer.update();
		});

		window.onMouseMove.add((x, y) ->
		{
			mosaic.footprint.x = (x / peoteView.zoom) - mosaic.footprint.mid_width;
			mosaic.footprint.y = (y / peoteView.zoom) - mosaic.footprint.mid_height;
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
