package nes;

import peote.view.Color;
import peote.view.TextureFormat;

var lospec_palette:Array<RGB> = [
	0xfcfcfc, // 0x00
	0xa4e4fc, // 0x01
	0xb8b8f8, // 0x02
	0xd8b8f8, // 0x03
	0xf8b8f8, // 0x04
	0xf8a4c0, // 0x05
	0xf0d0b0, // 0x06
	0xfce0a8, // 0x07
	0xf8d878, // 0x08
	0xd8f878, // 0x09
	0xb8f8b8, // 0x0a
	0xb8f8d8, // 0x0b
	0x00fcfc, // 0x0c
	0x000000, // 0x0d
	0x000000, // 0x0e
	0x000000, // 0x0f
	0xf8f8f8, // 0x10
	0x3cbcfc, // 0x11
	0x6888fc, // 0x12
	0x9878f8, // 0x13
	0xf878f8, // 0x14
	0xf85898, // 0x15
	0xf87858, // 0x16
	0xfca044, // 0x17
	0xf8b800, // 0x18
	0xb8f818, // 0x19
	0x58d854, // 0x1a
	0x58f898, // 0x1b
	0x00e8d8, // 0x1c
	0x000000, // 0x1d
	0x000000, // 0x1e
	0x000000, // 0x1f
	0xbcbcbc, // 0x20
	0x0078f8, // 0x21
	0x0058f8, // 0x22
	0x6844fc, // 0x23
	0xd800cc, // 0x24
	0xe40058, // 0x25
	0xf83800, // 0x26
	0xe45c10, // 0x27
	0xac7c00, // 0x28
	0x00b800, // 0x29
	0x00a800, // 0x2a
	0x00a844, // 0x2b
	0x008888, // 0x2c
	0xf8d8f8, // 0x2d
	0x000000, // 0x2e
	0x000000, // 0x2f
	0x7c7c7c, // 0x30
	0x0000fc, // 0x31
	0x0000bc, // 0x32
	0x4428bc, // 0x33
	0x940084, // 0x34
	0xa80020, // 0x35
	0xa81000, // 0x36
	0x881400, // 0x37
	0x503000, // 0x38
	0x007800, // 0x39
	0x006800, // 0x3a
	0x005800, // 0x3b
	0x004058, // 0x3c
	0x787878, // 0x3d
	0x000000, // 0x3e
	0x000000, // 0x3f
];

var fade00:Array<Int> = [
	//
	0x1f, // 0x000000
	0x2f, // 0x000000
	0x3f, // 0x000000
];

var fade01:Array<Int> = [
	//
	0x20, // 0xbcbcbc
	0x30, // 0x7c7c7c,
	0x3d, // 0x787878
];

var fade02:Array<Int> = [
	//
	0x20, // 0xbcbcbc
	0x30, // 0x7c7c7c,
	0x3d, // 0x787878
];

class PaletteMap extends Texture
{
	var data:TextureData;
	var debugElement:Quad;

	public function new()
	{
		super(256, 1, null, {
			format: TextureFormat.RGBA,
		});

		data = new TextureData(256, 1, TextureFormat.RGBA);

		var defaultIndexes:Array<Int> = [
			//
			0x00,
			0x03,
			0x13,
			0x23,
			//
			0x00,
			0x09,
			0x19,
			0x29,
			//
			0x00,
			0x0c,
			0x1c,
			0x2c,
			//
			0x00,
			0x05,
			0x15,
			0x25,
		];

		// set defaults on bg 
		for (x in 0...defaultIndexes.length)
		{
			var c:Color = 0x000000FF;
			c.r = defaultIndexes[x];
			data.setColor(x, 0, c);
		}

		// set defaults on fg 
		for (x in 0...defaultIndexes.length)
		{
			var c:Color = 0x000000FF;
			c.r = defaultIndexes[x];
			data.setColor(x + 16, 0, c);
		}

		this.setData(data);
	}

	/**
	 * Set the color index for an entry in one of the Sprite palettes
	 * @param palette this is the index of the palette; range 0~3
	 * @param index this is the index within the palette; range 1~3
	 * @param color this is the index of the color in the global palette, range 0~54
	 */
	public function changeBackgroundColor(palette:Int, index:Int, color:Int)
	{
		// offset the index, 4 colors per palette
		var position = (4 * palette) + index;
		var c:Color = 0x000000FF;
		c.r = color;
		data.setColor(position, 0, c);

		// data.setRed(position, 0, color);
		this.setData(data);
	}

	/**
	 * Set the color index for an entry in one of the Sprite palettes
	 * @param palette this is the index of the palette; range 0~3
	 * @param index this is the index within the palette; range 1~3
	 * @param color this is the index of the color in the global palette, range 0~54
	 */
	public function changeSpriteColor(palette:Int, index:Int, color:Int)
	{
		var position = 16 + (4 * palette) + index;
		var c:Color = 0x000000FF;
		c.r = color;

		data.setColor(position, 0, c);
		this.setData(data);
	}

	var backup:Array<Int> = [];

	public function blacken()
	{
		for (x in 0...data.width)
		{
			backup[x] = data.getColor(x, 0);
			data.setColor(x, 0, 0x0f0000ff);
		}
		this.setData(data);
		fadeDarkIndex = 0;
	}

	public function fadeOut():Bool
	{
		return true;
		// todo
	}

	var fadeDarkIndex = 0;
	var fadeLightIndex = 0;
	var darks:Array<Array<Int>> = [fade00, fade01, fade02];

	public function fadeIn():Bool
	{
		var isFading = fadeDarkIndex < darks.length;
		if (isFading)
		{
			for (x in 0...32)
			{
				var c:Color = 0x000000FF;
				c.r = darks[fadeDarkIndex][x % 4];

				data.setColor(x, 0, c);
			}
			fadeDarkIndex++;
		}
		else
		{
			for (x in 0...32)
			{
				data.setColor(x, 0, backup[x]);
			}
		}

		this.setData(data);
		return !isFading;
	}

	public function debug(uncoloredDisplay:Display, coloredDisplay:Display, scaleY:Int = 8)
	{
		if (debugElement == null)
		{
			var height = this.height * scaleY;

			var buffer = new QuadBuffer(1);
			buffer.program.addTexture(this);
			buffer.addToDisplay(uncoloredDisplay);
			debugElement = buffer.addElement(new Quad(this.width, height));

			var buffer = new QuadBuffer(1);
			buffer.program.addTexture(this);
			buffer.addToDisplay(coloredDisplay);
			debugElement = buffer.addElement(new Quad(this.width, height, 0.0, height));
		}
	}
}
