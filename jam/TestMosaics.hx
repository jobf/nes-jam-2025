import kiss.graphics.AnimateTile;
import kiss.graphics.PeoteView;
import LdtkData.read_animations;
import lime.app.Application;
import lime.utils.Assets;
import nes.Nametable.TileIndex;
import nes.Palette;
import nes.Tiles.TileSetter;
import peote.view.Display;
import peote.view.TextureData;

class TestMosaics extends Application
{
	override function onPreloadComplete()
	{
		var peoteView = new PeoteView(window);
		peoteView.zoom = 4;

		var uncoloredDisplay = new Display(0, 0, window.width, window.height, 0xf040f0ff);
		peoteView.addDisplay(uncoloredDisplay);

		var tilesData:Array<TextureData> = [
			Assets.getImage("assets/tiles.png"),
			Assets.getImage("assets/sprites.png") // todo - should migrate to tiles only?
		];

		var tiles = new TileSetter(peoteView, tilesData, lospec_palette);
		tiles.addToDisplay(uncoloredDisplay);

		/** this will be background scenery and default tiles **/
		var scenery = new Mosaic({
			x: 0,
			y: 0,
			width: 32,
			height: 32
		});
		scenery.draw(tiles.setLevelTile);

		/** this will be foreground scenery **/
		var scenery = new Mosaic({
			x: 64,
			y: 16,
			width: 16,
			height: 16
		});
		scenery.arrange([
			new TileIndex(1, 64), new TileIndex(1, 65),
			new TileIndex(1, 128), new TileIndex(1, 129),
		]);
		scenery.draw(tiles.setLevelTile);

		/** this will be background scenery **/
		var scenery = new Mosaic({
			x: 16,
			y: 64,
			width: 6 * 8,
			height: 3 * 8
		});
		scenery.arrange([
			154, 155, 156, 157, 158, 159,
			218, 219, 220, 221, 222, 223,
			282, 283, 284, 285, 286, 287,
		]);
		scenery.draw(tiles.setLevelTile);

		// sprite for moving around to check background/foreground
		var sprite = tiles.sprite();
		if (sprite == null)
		{
			trace("this shouldn't happen because we have not used any sprites yet...");
		}
		else
		{
			sprite.changeTile(1);
			sprite.changePalette(2);
			window.onMouseMove.add((x, y) -> sprite.move(x / peoteView.zoom, y / peoteView.zoom));
		}

		var ldtk_data = new LdtkData();
		var level = ldtk_data.worlds[0].levels[5];
		var animation = level.l_Entities.all_Animation.filter(animation -> animation.f_Name == "Frog")[0];
		var animations = read_animations(level.l_Entities.all_Animation, level.l_Tiles);
		var frog = animations["Frog"];
		// trace(frog.frames);

		var column:Int = Std.int(64 / 8);
		var row:Int = Std.int(64 /8);
		
		var animator = new AnimateMosaic([animation.f_Name => frog], tiles.setLevelTile, column, row);
		animator.play_animation(animation.f_Name);

		// send element data to GPU
		onUpdate.add(i ->{ 
			tiles.draw();
		});

		window.onKeyDown.add((code, modifier) -> switch code
		{
			case NUMBER_0: animator.step();
			case NUMBER_1: animator.change_frame();
			case NUMBER_2: animator.isFlipped = true;
			case NUMBER_3: animator.isFlipped = false;
			case NUMBER_4:
			case NUMBER_5:
			case NUMBER_6:
			case NUMBER_7:
			case NUMBER_8:
			case NUMBER_9:
			case _: return;
		});
	}
}
