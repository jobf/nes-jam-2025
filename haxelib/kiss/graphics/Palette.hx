package kiss.graphics;

import kiss.graphics.RGB;
import peote.view.TextureData;

@:forward(width, height)
abstract Palette(TextureData) to TextureData
{
	public function new(entries:Array<RGB>)
	{
		this = new TextureData(0xff, 1);
		for (x in 0...entries.length)
		{
			this.setColor_RGBA(x, 0, entries[x]);
		}

		for (x in entries.length...this.width)
		{
			this.setColor_RGBA(x, 0, 0x000000ff);
		}
	}
}
