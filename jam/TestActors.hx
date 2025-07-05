import LdtkData.read_animations;
import kiss.util.Rectangle;
import kiss.graphics.Palette;
import kiss.graphics.PeoteView;
import lime.app.Application;
import lime.utils.Assets;
import nes.Palette;
import nes.Tiles;
import peote.view.Display;
import peote.view.Texture;

class TestActors extends Application
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

		var ldtk_data = new LdtkData();
		var level = ldtk_data.worlds[0].levels[5];
		var animations = read_animations(level.l_Entities.all_Animation, level.l_Tiles);
		var test = animations["Hero"];
		var size = test.frame_columns * tileSize;
		var actor = new Actor(animations, 0, 0, size, size, 8, {
			jumpFramesAscent: 8,
			jumpFramesDescent: 4,
			jumpFramesCoyote: 3,
			jumpFramesBuffer: 3,
			jumpHeightTilesMax: 4,
			jumpHeightTilesMin: 1,
		}, (grid_x, grid_y) -> return 0);

		actor.animation.play_animation("Hero_Kiss");

		onUpdate.add(i ->
		{
			// set all sprite tiles to empty
			cycle.clear();

			actor.draw(1, cycle.setTile);

			// update gpu
			buffer.update();
		});

		window.onMouseMove.add((xm, ym) ->
		{
			var x = (xm / peoteView.zoom);// - mosaic.footprint.mid_width;
			var y = (ym / peoteView.zoom);// - mosaic.footprint.mid_height;
			actor.movement.teleport_to(x, y);
			// actor.sprite.move(x, y);
		});

		window.onKeyDown.add((code, modifier) -> switch code
		{
			case NUMBER_0: actor.animation.step();
			case NUMBER_1: actor.animation.play_animation("Hero");
			case NUMBER_2: actor.animation.play_animation("Hero_Walk");
			case NUMBER_3: actor.animation.play_animation("Hero_Jump");
			case NUMBER_4: actor.animation.play_animation("Hero_Kiss");
			case NUMBER_5:
			case NUMBER_6:
			case NUMBER_7:
			case NUMBER_8:
			case NUMBER_9:
			case _: return;
		});
	}
}
