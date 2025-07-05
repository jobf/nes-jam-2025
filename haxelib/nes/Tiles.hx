package nes;

import kiss.util.Cycle;
import nes.Nametable;
import nes.Palette;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;
import peote.view.Texture;
import peote.view.UniformFloat;


@:publicFields
class Tile implements Element
{
	/**
		position on x axis
	**/
	@posX var x:Int;

	/**
		position on y axis
	**/
	@posY var y:Int;

	/**
		width in pixels
	**/
	@sizeX var width:Int;

	/**
		height in pixels
	**/
	@sizeY var height:Int;

	/**
	 * which slot of tiles (refers to texture slot)
	 */
	@texSlot var slot:Int = 0;

	/**
	 * which tile in the bank
	 */
	@texTile var tile:Int = 0;

	/**
	 * used internally to offset the palette mapping,
	 * set it via changePalette function
	 */
	@custom @varying private var paletteOffset:Float = 0.0;

	/**
	 * used to flip the element horizontally
	 * set it via isFlippedX
	 */
	@custom @varying private var mirrorX:Float = 0.0;

	var isFlippedX(get, set):Bool;

	/**
	 * used to flip the element vertically
	 * set it via isFlippedY
	 */
	@custom @varying private var mirrorY:Float = 0.0;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivotX") var pivotX:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivotY") var pivotY:Float = 0.0;

	var isFlippedY(get, set):Bool;

	var OPTIONS = {blend: true};

	function new(x:Float = 0, y:Float = 0, tile:Int = 0, paletteIndex:Int = 0, paletteLayer:Int = 0, height:Float = 8, width:Float = 8)
	{
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.width = Std.int(width);
		this.height = Std.int(height);
		this.tile = tile;

		if (paletteLayer == 0)
		{
			changeBgPalette(paletteIndex);
		}
		else
		{
			changeFgPalette(paletteIndex);
		}
	}

	/**
	 * Color the tile using a background palette
	 * @param index of the palette - can be 0 to 3 inclusive
	 */
	function changeBgPalette(index:Int)
	{
		// return early if outside valid index range
		if (index < 0 || index > 3)
			return;

		var paletteStart = (index * 4);
		paletteOffset = paletteStart / 256;
	}

	/**
	 * Color the tile using a foreground palette
	 * @param index of the palette - can be 0 to 3 inclusive
	 */
	function changeFgPalette(index:Int)
	{
		// return early if outside valid index range
		if (index < 0 || index > 3)
			return;

		paletteOffset = ((index * 4) + 16) / 256;
	}

	private function set_isFlippedX(isFlipped:Bool):Bool
	{
		mirrorX = isFlipped ? 1.0 : 0.0;
		return isFlipped;
	}

	private function get_isFlippedX():Bool
	{
		return mirrorX == 1.0;
	}

	private function set_isFlippedY(isFlipped:Bool):Bool
	{
		mirrorY = isFlipped ? 1.0 : 0.0;
		return isFlipped;
	}

	private function get_isFlippedY():Bool
	{
		return mirrorY == 1.0;
	}
}

class TileBuffer extends Buffer<Tile>
{
	static public var tileSize:Int = 8;

	public var program(default, null):Program;

	var mix:UniformFloat;

	public function new(size:Int, tiles:Texture, paletteIndexes:Texture)
	{
		super(size, size);
		program = new Program(this);
		program.snapToPixel(1);

		mix = new UniformFloat("u_mapMix", 0.0);
		// mix.value = 1.0; // change this to 1.0 to show original colors, before the final mapping

		program.addTexture(tiles);
		program.addTexture(paletteIndexes, "indexes");
		program.injectIntoFragmentShader("
		vec4 mapToR(int textureID, int indexesID, float paletteOffset, float mirrorX, float mirrorY)
		{
			// remap coord based on mirror setup
			float x = abs(mirrorX - vTexCoord.x);
			float y = abs(mirrorY - vTexCoord.y);

			// sample the tiles texture
			vec4 texColor = getTextureColor(textureID, vec2(x, y));
			
			// sample the framebuffer texture (which has the palette indexes on)
			vec2 indexesXY = vec2(texColor.r + paletteOffset, 0.5);
			vec4 indexesColor = getTextureColor(indexesID, indexesXY);

			// return combination of the palette index and the tile alpha
			vec4 red = vec4(indexesColor.rgb, texColor.a);
			return mix(red, texColor, u_mapMix);
		}
		", false, [mix]);

		program.setColorFormula('mapToR(default_ID, indexes_ID, paletteOffset, mirrorX, mirrorY)');
	}

	public function addToDisplay(display:Display)
	{
		display.addProgram(program);
	}

	public function reloadTexture(tex:Texture)
	{
		program.setTexture(tex);
	}
}

class TileSetter
{
	public static var EmptySpriteId:Int = 0;

	public var levelTileCount = Nametable.tileCols * Nametable.tileRows;

	var levelBack:TileBuffer;
	var levelFront:TileBuffer;

	var spriteSize:Int = 32;
	var spriteCount = 64;
	var nextSprite:Int;

	
	var spritesBuffer:TileBuffer;
	public var spriteTiles:TileCycle;

	public var palettes(default, null):PaletteMap;

	var colorsDisplay:FramebufferDisplay;
	var mix:UniformFloat;

	public var textOverlay:TextProgram;
	public var colors:Array<Int>;

	public function new(peoteView:PeoteView, tilesTextureData:Array<TextureData>, colors:Array<Int>)
	{
		this.colors = colors;
		palettes = new PaletteMap();

		var data = tilesTextureData[0];
		var tiles = Texture.fromData(data);
		tiles.tilesX = Std.int(data.width / TileBuffer.tileSize);
		tiles.tilesY = Std.int(data.height / TileBuffer.tileSize);
		initLevelTileSetter(tiles);

		var data = tilesTextureData[1];
		var tex = Texture.fromData(data);
		tex.tilesX = Std.int(data.width / spriteSize);
		tex.tilesY = Std.int(data.height / spriteSize);
		trace('sprites tilesX ${tex.tilesX}  tilesY ${tex.tilesY} ');
		initSpriteTileSetter(tex);
		TileSetter.EmptySpriteId = tex.tilesX * tex.tilesY;
		nextSprite = spriteCount;

		textOverlay = new TextProgram();

		colorsDisplay = new FramebufferDisplay(peoteView, peoteView.width, peoteView.height);

		mix = new UniformFloat("u_mapMix", 0.0);
		// mix.value = 1.0; // change this to 1.0 to show original colors, before the final mapping
		colorsDisplay.fbo.program.addTexture(Texture.fromData(new Palette(colors)), "palette");
		colorsDisplay.fbo.program.injectIntoFragmentShader("
			vec4 mapToPalette(int textureID, int paletteID)
			{
				vec4 indexColor = getTextureColor(textureID, vTexCoord);
				vec2 palXY = vec2(indexColor.r, 0.5);
				vec4 palColor = getTextureColor(paletteID, palXY);
				return mix(vec4(palColor.rgb, indexColor.a), indexColor, u_mapMix);
			}
		", false, [mix]);

		colorsDisplay.fbo.program.setColorFormula('mapToPalette(default_ID, palette_ID)');

		levelBack.addToDisplay(colorsDisplay);
		spritesBuffer.addToDisplay(colorsDisplay);
		levelFront.addToDisplay(colorsDisplay);
		textOverlay.addToDisplay(colorsDisplay);
	}

	public function draw()
	{
		levelBack.update();
		levelFront.update();
		spritesBuffer.update();
		textOverlay.updateAll();
	}

	public function addToDisplay(display:Display)
	{
		colorsDisplay.fbo.addToDisplay(display);
	}

	inline function initLevelTileSetter(tiles:Texture):Void
	{
		levelBack = new TileBuffer(levelTileCount, tiles, palettes);
		levelFront = new TileBuffer(levelTileCount, tiles, palettes);

		for (n in 0...levelTileCount)
		{
			var x = 8 * Nametable.tileCols.column(n);
			var y = 8 * Nametable.tileCols.row(n);
			levelBack.addElement(new Tile(x, y, 0, 0));
			levelFront.addElement(new Tile(x, y, 0, 0));
		}
	}

	inline function initSpriteTileSetter(tiles:Texture):Void
	{
		spritesBuffer = new TileBuffer(spriteCount, tiles, palettes);
		spriteTiles = new TileCycle(spritesBuffer, spriteCount);
		// sprites = [
		// 	for (n in 0...spriteCount)
		// 	{
		// 		var f = new Tile(550, n * 8, 4, 1, 1, 32, 32);
		// 		f.pivotX = 0.5;
		// 		f.pivotY = 0.5;
		// 		var b = new Tile(550, n * 8, 4, 1, 1, 32, 32);
		// 		b.pivotX = 0.5;
		// 		b.pivotY = 0.5;
		// 		{
		// 			tile: spriteTiles.addElement(f),
		// 		}
		// 	}
		// ];
	}

	public function showTable(tileIndexes:Array<TileIndex>, palettes:Array<Int>, hazards:Array<Array<Tile>>)
	{
		var attributes = expandArray(palettes);
		for (i in 0...tileIndexes.length)
		{
			var back = levelBack.getElement(i);
			var front = levelFront.getElement(i);
			var tile = tileIndexes[i];
			if (tile.layer() == 0) // tile is background
			{
				back.tile = tile.index();
				front.tile = 0;
			}
			else
			{
				back.tile = 0;
				front.tile = tile.index();
			}

			var paletteIndex = attributes[i];
			if (paletteIndex == 1)
			{
				hazards.push([back, front]);
				back.changeBgPalette(0);
				front.changeBgPalette(0);
			}
			else
			{
				back.changeBgPalette(paletteIndex);
				front.changeBgPalette(paletteIndex);
			}
		}
	}

	// public function sprite(pivot:Float = 0.5):Sprite
	// {
	// 	return sprites.get();
	// 	var count = sprites.length;
	// 	// get sprites from the front to the back
	// 	while (count-- > 0)
	// 	{
	// 		var sprite = sprites[count];
	// 		if (!sprite.isUsed)
	// 		{
	// 			sprite.isUsed = true;
	// 			sprite.flipX(false);
	// 			sprite.flipY(false);
	// 			// sprite.changeTile(TileSetter.EmptySpriteId);
	// 			// sprite.tile.pivotX = pivot;
	// 			// sprite.tile.pivotY = pivot;
	// 			return sprite;
	// 		}
	// 	}
	// 	return null;
	// }

	// public function resetSprites(playerSprite:Sprite)
	// {
	// 	// for (sprite in sprites)
	// 	// {
	// 	// 	if (sprite != playerSprite)
	// 	// 	{
	// 	// 		sprite.isUsed = false;
	// 	// 		sprite.changeTile(TileSetter.EmptySpriteId);
	// 	// 		sprite.tile.changeBgPalette(0);
	// 	// 		sprite.move(-99, -99);
	// 	// 	}
	// 	// }
	// }

	public function reloadTextures(textureDatas:Array<TextureData>)
	{
		var data = textureDatas[0];
		var tex = Texture.fromData(data);
		tex.tilesX = Std.int(data.width / TileBuffer.tileSize);
		tex.tilesY = Std.int(data.height / TileBuffer.tileSize);
		levelBack.reloadTexture(tex);
		levelFront.reloadTexture(tex);

		var data = textureDatas[1];
		var tex = Texture.fromData(data);
		tex.tilesX = Std.int(data.width / spriteSize);
		tex.tilesY = Std.int(data.height / spriteSize);
		spritesBuffer.reloadTexture(tex);
		TileSetter.EmptySpriteId = tex.tilesX * tex.tilesY;
	}

	// public function countActive():Int
	// {
	// 	return sprites.filter(sprite -> sprite.isUsed).length;
	// }

	var paletteDebug:QuadBuffer;

	public function debug(uncoloredDisplay:Display)
	{
		palettes.debug(uncoloredDisplay, colorsDisplay);
	}

	public function setLevelTile(col:Int, row:Int, tile:TileIndex, isFlipped:Bool)
	{
		var i = Nametable.tileCols.index(col, row);
		var back = levelBack.getElement(i);
		back.isFlippedX = isFlipped;
		var front = levelFront.getElement(i);
		front.isFlippedX = isFlipped;

		if (tile.layer() == 0) // tile is background
		{
			back.tile = tile.index();
			front.tile = TileSetter.EmptySpriteId;
		}
		else
		{
			back.tile = TileSetter.EmptySpriteId;
			front.tile = tile.index();
		}
	}

	public function setSpriteTiles(sprite:Sprite){
		sprite.draw(spriteTiles.setTile);
	}
}

function expandArray(blocks:Array<Int>, blockWidth:Int = 16):Vector<Int>
{
	var blockHeight = Std.int(blocks.length / blockWidth);
	var tileWidth = blockWidth * 2;
	var tileHeight = blockHeight * 2;
	var tiles:Vector<Int> = new Vector(tileWidth * tileHeight, 0);

	for (row in 0...blockHeight)
	{
		for (col in 0...blockWidth)
		{
			var blockIndex = row * blockWidth + col;
			var value = blocks[blockIndex];

			// Top-left corner of where this block goes in the tile grid
			var tx = col * 2;
			var ty = row * 2;

			tiles[(ty) * tileWidth + (tx)] = value;
			tiles[(ty) * tileWidth + (tx + 1)] = value;
			tiles[(ty + 1) * tileWidth + (tx)] = value;
			tiles[(ty + 1) * tileWidth + (tx + 1)] = value;
		}
	}

	// trace(tiles);
	return tiles;
}

@:publicFields
class Sprite
{
	private var mosaic:Mosaic;
	private var paletteIndex:Int;

	public function new(mosaic:Mosaic, paletteIndex:Int){
		this.mosaic = mosaic;
		this.paletteIndex = paletteIndex;
	}

	function move(x:Float, y:Float)
	{
		mosaic.footprint.x = Math.round(x) - mosaic.footprint.mid_width;
		mosaic.footprint.y = Math.round(y) - mosaic.footprint.mid_height;
	}

	function changePalette(index:Int)
	{
		this.paletteIndex = index;
	}

	function changeTiles(tiles:Array<Int>)
	{
		mosaic.arrange(tiles);
	}

	function flipX(isFlipped:Bool)
	{
		mosaic.isFlipped = isFlipped;
	}

	function flipY(isFlipped:Bool)
	{
		// todo :-s
	}

	public function draw(setFreeTile:(x:Int, y:Int, tileIndex:TileIndex, isFlipped:Bool, paletteIndex:Int) -> Void){
		mosaic.drawFree(setFreeTile);
	}
}


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

	public function setTile(x:Int, y:Int, tileIndex:TileIndex, isFlipped:Bool, paletteIndex:Int):Void{
		var tile = get();
		tile.tile = tileIndex.index();
		tile.isFlippedX = isFlipped;
		tile.changeFgPalette(paletteIndex);
		tile.x = x;
		tile.y = y;
	}
}