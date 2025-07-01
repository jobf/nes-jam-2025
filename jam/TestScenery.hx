import kiss.graphics.AnimateMosaic;
import nes.Nametable.TileIndex;
import peote.view.TextureData;
import lime.utils.Assets;
import nes.Tiles.TileSetter;
import kiss.graphics.PeoteView;
import lime.app.Application;
import nes.Palette;
import peote.view.Display;

class TestScenery extends Application
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
		var scenery = new Scenery({
			x: 0,
			y: 0,
			width: 32,
			height: 32
		});
		scenery.draw(tiles.setTile);

		/** this will be foreground scenery **/
		var scenery = new Scenery({
			x: 64,
			y: 16,
			width: 16,
			height: 16
		});
		scenery.arrange([
			new TileIndex(1, 64), new TileIndex(1, 65),
			new TileIndex(1, 128), new TileIndex(1, 129),
		]);
		scenery.draw(tiles.setTile);

		/** this will be background scenery **/
		var scenery = new Scenery({
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
		scenery.draw(tiles.setTile);

		// // sprite for moving around to check background/foreground
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
		var frames:Array<Array<Int>> = [];
		var frameCount = Std.int(animation.width / animation.f_FrameWidth);
		var frameColumns = Std.int(animation.f_FrameWidth / 8);
		var frameRows = Std.int(animation.f_FrameHeight / 8);

		for(n in 0...frameCount)
		{
			var frameTiles:Array<Int> = [];
			var left = n * frameColumns;
			var right = left + frameColumns;
			for(r in 0...frameRows){
				for(c in left...right)	{
					var col = c + animation.cx;
					var row = r + animation.cy;
					var tile:Int = 0;
					if(level.l_Tiles.hasAnyTileAt(col, row)){
						var stack = level.l_Tiles.getTileStackAt(col, row);
						tile = stack[stack.length - 1].tileId;
					}
					frameTiles.push(tile);
				}
			}
			frames.push(frameTiles);
		}

		trace(frames);


		var scenery = new Scenery({
			x: 64,
			y: 64,
			width: animation.f_FrameWidth,
			height: animation.f_FrameHeight
		});

		scenery.arrange(frames[0]);
		scenery.draw(tiles.setTile);

		var column:Int = Std.int(64 / 8);
		var row:Int = Std.int(64 /8);
		var config:AnimationConfig = {
			mode: LOOP_TIMED,
			frames: frames,
			frame_rate: 4,
			frame_width: 4
		}
		var animator = new AnimateMosaic([animation.f_Name => config], tiles.setTile, column, row);
		animator.play_animation(animation.f_Name);

		// send element data to GPU
		onUpdate.add(i ->{ 
			animator.step();
			tiles.draw();
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
