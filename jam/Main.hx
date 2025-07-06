import kiss.graphics.AnimateTile;
import Actor;
import Emitter;
import LdtkData;
import nes.Tiles;
import kiss.App;
import kiss.graphics.Quad;
import kiss.input.Controller;

using kiss.util.Math.Grid2d;

import kiss.util.Math;
import kiss.util.Rectangle;
import kiss.util.Repeat;
import lime.utils.Assets;
import peote.view.Color;
import peote.view.Display;
import peote.view.text.Text;
import peote.view.TextureData;

class Main extends App
{
	var state:GameState = TITLE;
	var isPlayerUnderWater:Bool = false;

	var tiles:TileSetter;
	var player:Actor;
	var levelLabel:Text;
	var debugging:QuadBuffer;
	var playerTracker:Quad;

	var input:Input;
	var controller:ControllerActions;
	var uncontroller:ControllerActions = {};

	var levelIndex:Int = 0;
	var levels:Array<Int> = [];

	var playerEntity:Entity_Player;
	var level:LdtkData_Level;
	var locks:Array<Hotspot> = [];
	var frogsKissed:Array<Hotspot> = [];
	var totalFrogs:Int = 0;

	var collisionsCoarse:Array<Int> = [];
	var floodable:Array<Array<Tile>> = [];
	var waterLevel:Int = 0;

	var titleCountdown:Countdown;
	var fadeCountdown:Countdown;
	var waitCountdown:Countdown;
	var waterChangeCountdown:Countdown;
	var loseBreathCountdown:Countdown;
	var escapeCountdown:Countdown;
	var kissEmit:Countdown;

	var hotReload:HotReload;
	var bubbler:Bubbler;
	var breather:Breather;
	var kisser:Kisser;
	var soaper:Soaper;
	var bubble:Particle;
	var breathsRemaining:Int = 2;
	var help:Tutorial;

	function init()
	{
		titleCountdown = new Countdown(1000);
		fadeCountdown = new Countdown(55);
		waitCountdown = new Countdown(1000);
		escapeCountdown = new Countdown(1000);
		escapeCountdown = new Countdown(1000);
		kissEmit = new Countdown(500);

		var colors = nes.Palette.lospec_palette;
		var tilesData:Array<TextureData> = [Assets.getImage("assets/tiles.png"), Assets.getImage("assets/sprites.png")];
		tiles = new TileSetter(peoteView, tilesData, colors);

		var display = new Display(0, 0, window.width, window.height, colors[0x0f]);
		peoteView.addDisplay(display);
		tiles.addToDisplay(display);
		levelIndex = 0;
		levelLabel = tiles.textOverlay.add(new Text(Std.int(256 / 2), Std.int(240 / 2), "", {
			fgColor: 0x060000ff,
			// bgColor: bgColor,
			// letterWidth: letterWidth,
			// letterHeight: letterHeight,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		}));

		input = new Input(window);

		debugging = new QuadBuffer(256);
		debugging.addToDisplay(console.display);
		playerTracker = debugging.addElement(new Quad(8, 8, Color.GREEN, true));

		state = TITLE;
		var rootPath = "../../../jam/";
		var ldtkAssetPath = "assets/levels.ldtk";
		hotReload = new HotReload(rootPath, ldtkAssetPath, () ->
		{
			player.sprite.changePalette(0);
			state = ANNOUNCE;
			tiles.palettes.blacken();

			var tilesData:Array<TextureData> = [
				hotReload.load_image("assets/tiles.png"),
				hotReload.load_image("assets/sprites.png")
			];

			levels = hotReload.ldtk_data.worlds[0].levels[0].f_LevelIndexes;
			levelIndex = hotReload.ldtk_data.worlds[0].levels[0].f_LevelIndexStart;

			tiles.reloadTextures(tilesData);
			tiles.resetSprites(player.sprite);
		});

		levels = hotReload.ldtk_data.worlds[0].levels[0].f_LevelIndexes;
		levelIndex = hotReload.ldtk_data.worlds[0].levels[0].f_LevelIndexStart;

		var stats:EntityStats = {
			jumpFramesAscent: 8,
			jumpFramesDescent: 4,
			jumpFramesCoyote: 3,
			jumpFramesBuffer: 3,
			jumpHeightTilesMax: 4,
			jumpHeightTilesMin: 1,
			// speedHorizontal: 0,
			// frictionHorizontal: 0
		}
		var animationsLevel = hotReload.ldtk_data.worlds[0].levels[5];
		var mosaicAnims = read_animations(animationsLevel.l_Entities.all_Animation, animationsLevel.l_Tiles);

		player = new Actor(mosaicAnims, -10, -10, 32, 32, 8, stats, getCollision);
		player.animation.play_animation("Hero");
		#if debug
		console.addLabel(() -> "x: " + player.movement.position.x);
		console.addLabel(() -> "y: " + player.movement.position.y);
		console.addLabel(() -> "s x: " + player.sprite.x);
		console.addLabel(() -> "s y: " + player.sprite.y);
		console.addLabel(() -> "col: " + Std.int(player.movement.position.grid_x));
		console.addLabel(() -> "col % : " + Std.int(player.movement.position.grid_cell_ratio_x));
		console.addLabel(() -> "row: " + Std.int(player.movement.position.grid_y));
		console.addLabel(() -> "row % : " + Std.int(player.movement.position.grid_cell_ratio_y));
		// console.addLabel(() -> "col check: " + player.movement.position.grid_x);
		// console.addLabel(() -> "row check: " + player.movement.position.grid_y);
		// console.addLabel(() -> "L: " + player.movement.neighbours.is_wall_left);
		// console.addLabel(() -> "R: " + player.movement.neighbours.is_wall_right);
		// console.addLabel(() -> "U: " + player.movement.neighbours.is_wall_up);
		// console.addLabel(() -> "D: " + player.movement.neighbours.is_wall_down);
		// console.addLabel(() -> "H: " + player.movement.neighbours.wall_here);
		console.addLabel(() -> "breathes remaining: " + breathsRemaining);
		var collisionColors:Map<Int, Color> = [0 => 0x10101010, 1 => 0xa0a090a0, 2 => 0xd05050a0];
		console.addTilemap(32, 30, 8, getCollision, collisionColors);
		tiles.debug(console.display);
		#end

		soaper = new Soaper();
		bubbler = new Bubbler();
		breather = new Breather();
		kisser = new Kisser();
		var helpText = tiles.textOverlay.add(new Text(Std.int(256 / 2), Std.int(240 / 2) - 16, "", {
			fgColor: 0x0f0000ff,
			// bgColor: bgColor,
			// letterWidth: letterWidth,
			// letterHeight: letterHeight,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		}));
		help = new Tutorial(helpText);
		controller = {
			left: {
				on_press: () -> pressLeft(),
				on_release: () -> releaseLeft()
			},

			right: {
				on_press: () -> pressRight(),
				on_release: () -> releaseRight()
			},

			a: {
				on_press: () -> pressA(),
				on_release: () -> releaseA()
			},

			b: {
				on_press: () -> pressB(),
				on_release: () -> releaseB(),
			}
			// start: start,
			// select: select
		}

		input.change_target(controller);
	}

	function pressLeft()
	{
		player.move_in_direction_x(-1);
		help.press(LEFT);
	}

	function releaseLeft()
	{
		player.stop_x();
		help.release(LEFT);
	}

	function pressRight()
	{
		player.move_in_direction_x(1);
		help.press(RIGHT);
	}

	function releaseRight()
	{
		player.stop_x();
		help.release(RIGHT);
	}

	function pressA()
	{
		player.jump();
		help.press(A);
	}

	function releaseA()
	{
		player.drop();
		help.release(A);
	}

	function pressB()
	{
		makeBubble();
		help.press(B);
		if (level.f_IsTutorial && bubblesCollected.length < level.f_InitialBubblesCollected)
		{
			for (hotspot in locks)
			{
				if (hotspot.style == TUTOR)
				{
					hotspot.isEnabled = true;
					hotspot.showInitialFrame();
					help.setMessages(["5000:Approach the frog!"]);
				}
			}
		}
	}

	function releaseB()
	{
		help.release(B);
	}

	function readHotspots(hotspots:Array<Entity_Hotspots>, collisionsCoarse:Array<Int>):Array<Hotspot>
	{

		var entityLevel = hotReload.ldtk_data.worlds[0].levels[5];
		var animations = read_animations(entityLevel.l_Entities.all_Animation, entityLevel.l_Tiles);

		frogsKissed = [];
		totalFrogs = 0;
		waterChangeCountdown = new Countdown(level.f_WaterRaiseDuration);
		loseBreathCountdown = new Countdown(level.f_LoseBreathDuration);
		bubblesCollected = [];
		bubbler.mode = AIR; // default to air
		help.isEnabled = level.f_Messages.length > 0;
		var animationName:String = "Frog";

		return [
			for (hotspotDef in hotspots)
			{
				var footprint:Rectangle = {
					x: Std.int(hotspotDef.cx * 8),
					y: Std.int(hotspotDef.cy * 8),
					width: hotspotDef.width,
					height: hotspotDef.height
				}
				var onUnlock:() -> Void = null;
				var duration = msToFrames(hotspotDef.f_UnlockDurationMs);
				var sprite = tiles.sprite();
				switch hotspotDef.f_HotspotStyle
				{
					case FROG:
						totalFrogs++;
					case TUTOR:
						totalFrogs++;
						onUnlock = () ->
						{
							help.clearMessages();
						}
					case UNBLOCK:
						if (hotspotDef.f_Blockage != null)
						{
							var blockage = level.l_Entities.all_Blockage.filter(entity -> entity.iid == hotspotDef.f_Blockage.entityIid)[0];
							if (blockage != null)
							{
								duration = msToFrames(blockage.f_UnlockDurationMs);
								blockPassage(blockage, collisionsCoarse, onUnlock);
							}
							animationName = "Unblock";
						}
					case SOAP:
						duration = msToFrames(333);
						animationName = "Soap";
						onUnlock = () ->
						{
							soaper.emitParticle(tiles.sprite()); // todo: finish this
							duration = msToFrames(100);
							soaper.x_start = footprint.x;
							soaper.y_start = footprint.y;
							bubbler.mode = SOAP;
							for (sprite in bubblesCollected)
							{
								sprite.changePalette(3);
							}
						}
					case BUBBLE:
						duration = 0;
						animationName = "Bubble";
						onUnlock = () ->
						{
							collectBubble();
						}
				}
				var mosaic = new Mosaic(footprint);
				// var animation = new AnimateMosaic(animations, mosaic);
				var spot = new Hotspot(mosaic, animations, duration, hotspotDef.f_HotspotStyle, onUnlock);
				spot.animation.play_animation(animationName);
				// spot.animation.step();
				spot;
			}
		];
	}

	function blockPassage(blockage:LdtkData.Entity_Blockage, collisionsCoarse:Array<Int>, onUnlock:() -> Void):Void
	{
		static var width_tiles:Int = 32;

		var sprite = tiles.sprite(0.0);
		sprite.changeTile(64);
		sprite.move(blockage.cx * 8, blockage.cy * 8);

		var col = blockage.cx;
		var row = blockage.cy;
		var width = Std.int(blockage.width / 8);
		var height = Std.int(blockage.height / 8);
		var reset:Array<Int> = [];
		for (r in row...row + height)
		{
			for (c in col...col + width)
			{
				var i = width_tiles.index(c, r);
				reset.push(i);
				collisionsCoarse[i] = 1;
			}
		}
		var isVertical = true;
		if (isVertical)
		{
			var length = Std.int(blockage.height / 8);
			for (n in blockage.cy...blockage.cy + length)
			{
				var i = width_tiles.index(blockage.cx, blockage.cy + n);
				reset.push(i);
				collisionsCoarse[i] = 1;
			}
		}

		onUnlock = () ->
		{
			for (i in reset)
			{
				collisionsCoarse[i] = 0;
				sprite.changeTile(TileSetter.EmptySpriteId);
				sprite.isUsed = false;
			}
		}
	}

	var bubbleX:Int = 16;
	var bubbleY:Int = 16;
	var bubblesCollected:Array<Sprite> = [];

	function collectBubble()
	{
		if (bubblesCollected.length < 5)
		{
			var x = bubbleX + (bubblesCollected.length * (16 + 6));
			var y = bubbleY;
			var sprite = tiles.sprite();
			sprite.changeTile(52);
			if (bubbler.mode == SOAP)
			{
				sprite.changePalette(3);
			}
			else
			{
				sprite.changePalette(0);
			}
			sprite.move(x, y);
			// bubblesCollected.push(sprite); todo!!
		}
	}

	function makeBubble()
	{
		if (bubbler.mode == SOAP && bubble != null)
		{
			bubbler.solidfy();
			bubble = null;
			return;
		}

		if (bubblesCollected.length <= 0)
			return;

		if (isPlayerUnderWater && breathsRemaining > 0)
		{
			switch bubbler.mode
			{
				case AIR:
					// emit bubble
					var offsetCol = player.facing == 1 ? 2 : -2;
					bubbler.x_start = player.movement.position.x;
					bubbler.y_start = player.movement.position.y - 18;
					bubbler.emitParticle(tiles.sprite());

					loseBreathCountdown.reset();
					// increase available breaths
					if (breathsRemaining == 1)
					{
						breathsRemaining++;
					}

					// spend a collected bubble
					var sprite = bubblesCollected.pop();
					sprite.clear();
					sprite.changePalette(0);

				case SOAP:
					if (bubble == null)
					{
						// emit bubble
						var offsetCol = player.facing == 1 ? 2 : -2;
						bubbler.x_start = (player.movement.position.grid_x + offsetCol) * 8;
						bubbler.y_start = player.movement.position.grid_y * 8;
						bubble = bubbler.emitParticle(tiles.sprite());
						bubble.sprite.changePalette(3);

						// increase available breaths
						if (breathsRemaining == 1)
						{
							breathsRemaining++;
						}

						// spend a collected bubble
						var sprite = bubblesCollected.pop();
						sprite.clear();
						sprite.changePalette(3);
					}
			}
		}
	}

	function isUnderWaterLevel(y:Float):Bool
	{
		return Std.int((y - 24) / 16) > (waterLevel - 1);
	}

	static var width_tiles:Int = 32;
	static var height_tiles:Int = 30;

	inline function is_out_of_bounds(grid_x:Int, grid_y:Int):Bool
	{
		return grid_x < 0 || grid_y < 0 || width_tiles <= grid_x || height_tiles <= grid_y;
	}

	function getCollision(column:Int, row:Int):Int
	{
		if (is_out_of_bounds(column, row))
		{
			return 1;
		}

		var i = width_tiles.index(column, row);

		var it = collisionsCoarse[i];
		return it;
	}

	var stateChange:GameState = TITLE;

	function stepFixed()
	{
		if (state != stateChange)
		{
			trace('change state ' + state);
			stateChange = state;
		}
		if (tiles == null)
			return;
		#if hotreload
		hotReload.update();
		#end

		help.update();
		if (breathsRemaining > 0)
		{
			player.update();
		}

		// player.animation.step();
		switch state
		{
			case TITLE:
				// todo
				state = ANNOUNCE;
				tiles.palettes.changeBackgroundColor(0, 1, 0x0f);
			case ANNOUNCE:
				if (levelLabel.text == "")
				{
					var label = ' COURSE ${levelIndex + 1} of ' + levels.length;
					levelLabel.text = label;
					levelLabel.x = Std.int((256 / 2) - (label.length * 8));
					titleCountdown.reset();
				}
				else
				{
					if (titleCountdown.remaining > 0)
					{
						titleCountdown.remaining--;
					}
					else
					{
						player.animation.play_animation("Hero");

						// next state
						state = WAIT;
						waitCountdown.reset();

						levelLabel.text = "";
						tiles.palettes.blacken();

						level = hotReload.ldtk_data.worlds[0].levels[levels[levelIndex]];

						tiles.showTable(readLevel(level.l_Tiles, level.l_Front), readAttributes(level.l_Palettes), floodable);
						waterLevel = level.f_WaterRow;

						collisionsCoarse = readCollisionsCoarse(level.l_CollisionCoarse);
						bubbler.collisions = collisionsCoarse;
						locks = readHotspots(level.l_Entities.all_Hotspots, collisionsCoarse);

						for (ent in level.l_Help.all_HELP)
						{
							switch ent.f_Help
							{
								case PAD:
									var sprite = tiles.sprite();
									sprite.changePalette(ent.f_PaletteIndex);
									sprite.move(ent.pixelX, ent.pixelY);
									help.showIntro(sprite);
								case EXIT:
									var sprite = tiles.sprite();
									sprite.changePalette(ent.f_PaletteIndex);
									sprite.changeTile(44);
									sprite.move(ent.pixelX, ent.pixelY);
							}
						}
					}
				}
			case WAIT:
				if (waitCountdown.remaining > 0)
				{
					waitCountdown.remaining--;
				}
				else
				{
					state = FADEIN;
					waitCountdown.reset();
				}
			case FADEIN:
				if (fadeCountdown.remaining > 0)
				{
					fadeCountdown.remaining--;
				}
				else
				{
					var isFadedIn = tiles.palettes.fadeIn();
					if (isFadedIn)
					{
						// next state
						state = PLAY;

						tiles.palettes.changeBackgroundColor(0, 1, convertToTileId(level.f_PaletteA1_infos));
						tiles.palettes.changeBackgroundColor(0, 2, convertToTileId(level.f_PaletteA2_infos));
						tiles.palettes.changeBackgroundColor(0, 3, convertToTileId(level.f_PaletteA3_infos));
						tiles.palettes.changeBackgroundColor(1, 1, convertToTileId(level.f_PaletteB1_infos));
						tiles.palettes.changeBackgroundColor(1, 2, convertToTileId(level.f_PaletteB2_infos));
						tiles.palettes.changeBackgroundColor(1, 3, convertToTileId(level.f_PaletteB3_infos));
						tiles.palettes.changeBackgroundColor(2, 1, convertToTileId(level.f_PaletteC1_infos));
						tiles.palettes.changeBackgroundColor(2, 2, convertToTileId(level.f_PaletteC2_infos));
						tiles.palettes.changeBackgroundColor(2, 3, convertToTileId(level.f_PaletteC3_infos));
						tiles.palettes.changeBackgroundColor(3, 1, convertToTileId(level.f_PaletteD1_infos));
						tiles.palettes.changeBackgroundColor(3, 2, convertToTileId(level.f_PaletteD2_infos));
						tiles.palettes.changeBackgroundColor(3, 3, convertToTileId(level.f_PaletteD3_infos));

						// the foreground palettes
						var spriteLevel = hotReload.ldtk_data.worlds[0].levels[0];
						tiles.palettes.changeSpriteColor(0, 1, convertToTileId(spriteLevel.f_PaletteA1_infos));
						tiles.palettes.changeSpriteColor(0, 2, convertToTileId(spriteLevel.f_PaletteA2_infos));
						tiles.palettes.changeSpriteColor(0, 3, convertToTileId(spriteLevel.f_PaletteA3_infos));
						tiles.palettes.changeSpriteColor(1, 1, convertToTileId(spriteLevel.f_PaletteB1_infos));
						tiles.palettes.changeSpriteColor(1, 2, convertToTileId(spriteLevel.f_PaletteB2_infos));
						tiles.palettes.changeSpriteColor(1, 3, convertToTileId(spriteLevel.f_PaletteB3_infos));
						tiles.palettes.changeSpriteColor(2, 1, convertToTileId(spriteLevel.f_PaletteC1_infos));
						tiles.palettes.changeSpriteColor(2, 2, convertToTileId(spriteLevel.f_PaletteC2_infos));
						tiles.palettes.changeSpriteColor(2, 3, convertToTileId(spriteLevel.f_PaletteC3_infos));
						tiles.palettes.changeSpriteColor(3, 1, convertToTileId(spriteLevel.f_PaletteD1_infos));
						tiles.palettes.changeSpriteColor(3, 2, convertToTileId(spriteLevel.f_PaletteD2_infos));
						tiles.palettes.changeSpriteColor(3, 3, convertToTileId(spriteLevel.f_PaletteD3_infos));

						for (n in 0...level.f_InitialBubblesCollected)
						{
							collectBubble();
						}

						loseBreathCountdown.reset();
						waterChangeCountdown.reset();
						kissEmit.reset();
						// todo? reset all countdowns here??
						player.clearJumpBuffer();
						playerEntity = level.l_Entities.all_Player[0];
						trace('start ${levels[levelIndex]} : player at ' + playerEntity.cx + ' ' + playerEntity.cy + ' number of frogs $totalFrogs');
						player.movement.teleport_to_grid(playerEntity.cx, playerEntity.cy);
						player.facing = playerEntity.f_Facing;
						breathsRemaining = 2;

						bubbler.reset();
						kisser.reset();
						breather.reset();
						soaper.reset();
						if (level.f_IsTutorial || level.f_Messages.length > 0)
						{
							help.setMessages(level.f_Messages);
						}
					}
					else
					{
						fadeCountdown.reset();
					}
				}

			case PLAY:
				isPlayerUnderWater = isUnderWaterLevel(player.movement.position.y - 24);

				if (!isPlayerUnderWater)
				{
					breathsRemaining = 2;
					loseBreathCountdown.reset();
				}

				switch breathsRemaining
				{
					case 2:
						player.sprite.changePalette(0);
					case 1:
						player.sprite.changePalette(3);
					case 0:
						// todo - change palette FG 3 colors to match BG 3
						// level.f_PaletteA is the underwater palette, make Sprites palette use it
						// put it in Palette index 3 because of case:1
						tiles.palettes.changeSpriteColor(1, 1, convertToTileId(level.f_PaletteB1_infos));
						tiles.palettes.changeSpriteColor(1, 2, convertToTileId(level.f_PaletteB2_infos));
						tiles.palettes.changeSpriteColor(1, 3, convertToTileId(level.f_PaletteB3_infos));
				}

				bubbler.waterLevel = waterLevel;
				soaper.update();
				bubbler.update();
				breather.update();
				kisser.update();

				player.isOverlappingEntity = false;
				var animationCurrent = player.animation.now_playing_name;

				for (spot in locks)
				{
					if (!spot.isEnabled)
						continue;

					spot.update();
					spot.mosaic.drawFree(tiles.spriteTiles.setTile);

					if (spot.style == FROG || spot.style == TUTOR && spot.isLocked)
					{
						var isFlipped = player.movement.position.x < spot.mosaic.footprint.center_x;
						// spot.animation.isFlipped = isFlipped;
						spot.mosaic.isFlipped = isFlipped;
					}

					if (spot.overlap(player.movement.position.x, player.movement.position.y))
					{
						player.isOverlappingEntity = true;

						if (spot.style == FROG || spot.style == TUTOR)
						{
							if (spot.isLocked)
							{
								// frog is being kissed, play animation and emit kiss sprites
								player.animation.play_animation("Hero_Kiss");
								kisser.x_start = spot.mosaic.footprint.center_x;
								kisser.y_start = spot.mosaic.footprint.center_y - 10;
								kissEmit.remaining--;
								if (kissEmit.remaining < 0)
								{
									kissEmit.reset();
									kisser.emitParticle(tiles.sprite());
								}
							}
							else
							{
								if (!frogsKissed.contains(spot))
								{
									// frog has finished being kissed, keep track of that
									frogsKissed.push(spot);
								}
							}
						}
					}
					else
					{
						// not overlapping anything so return to previous animation
						player.animation.play_animation(animationCurrent);
						// todo store this better because sometimes we move from kiss back to kiss
						// trace('revert animation to $animationCurrent');
					}
				}

				player.isReachedGoal = frogsKissed.length > 0 && frogsKissed.length >= totalFrogs;
				if (player.isReachedGoal)
				{
					state = ESCAPED;
					escapeCountdown.reset();
					bubbler.clear();
					kisser.clear();
					soaper.clear();
					breather.clear();

					help.clearMessages();
				}
				else
				{
					if (waterChangeCountdown.remaining > 0)
					{
						waterChangeCountdown.remaining--;
					}
					else
					{
						waterChangeCountdown.reset();

						var next = floodable.filter(tiles -> isUnderWaterLevel(tiles[0].y));
						for (tiles in next)
						{
							for (t in tiles)
							{
								t.changeBgPalette(1); // 1 is the flooded (underwater) palette
							}
						}

						waterLevel--;

						if (isPlayerUnderWater)
						{
							if (loseBreathCountdown.remaining > 0)
							{
								loseBreathCountdown.remaining--;
								// trace('loseBreathCountdown.remaining ${loseBreathCountdown.remaining}');
							}
							else
							{
								loseBreathCountdown.reset();
								breathsRemaining--;
								breather.x_start = player.movement.position.x;
								breather.y_start = player.movement.position.y;
								for (n in 0...3)
								{
									breather.emitParticle(tiles.sprite());
									breather.y_start -= 9;
									breather.x_start + (Math.random() * 4);
								}

								if (breathsRemaining < 0)
								{
									state = DROWNED;
									player.sprite.changePalette(1);
									waitCountdown.reset();
								}
							}
						}
					}
				}
			case DROWNED:
				help.clearMessages();
				if (waitCountdown.remaining > 0)
				{
					waitCountdown.remaining--;
				}
				else
				{
					player.sprite.changePalette(0);
					tiles.palettes.blacken();
					state = TITLE;
					waitCountdown.reset();
					tiles.resetSprites(player.sprite);
				}
			case ESCAPED:
				player.sprite.changePalette(0);
				player.update();
				if (escapeCountdown.remaining > 0)
				{
					escapeCountdown.remaining--;
				}
				else
				{
					tiles.palettes.blacken();
					tiles.resetSprites(player.sprite);
					levelIndex = (levelIndex + 1) % levels.length;
					state = ANNOUNCE;
					// todo
					// state = FADEOUT;
					escapeCountdown.reset();
					player.movement.teleport_to_grid(-100, -100);
					player.update();
				}
			case FADEOUT:
				if (fadeCountdown.remaining > 0)
				{
					fadeCountdown.remaining--;
				}
				else
				{
					fadeCountdown.reset();
					var isFaded = tiles.palettes.fadeOut();
					if (isFaded)
					{
						// next state
						state = ANNOUNCE;
					}
				}
			case END:
		}
	}

	function stepDynamic(elapsedMs:Int) {}

	function draw(t:Float)
	{

		if (tiles == null || player == null)
			return;
		
		tiles.spriteTiles.clear();
		
		if (state == PLAY)
		{
			player.draw(t, tiles.spriteTiles.setTile);
			bubbler.draw(t, tiles.spriteTiles.setTile);
			breather.draw(t, tiles.spriteTiles.setTile);
			soaper.draw(t, tiles.spriteTiles.setTile);
			kisser.draw(t, tiles.spriteTiles.setTile);
		}
		
		tiles.draw();

		playerTracker.x = player.movement.position.x;
		playerTracker.y = player.movement.position.y;
		debugging.update();
	}
}

enum GameState
{
	TITLE;
	ANNOUNCE;
	WAIT;
	FADEIN;
	PLAY;
	DROWNED;
	ESCAPED;
	FADEOUT;
	END;
}
