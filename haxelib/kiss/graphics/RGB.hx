package kiss.graphics;

import peote.view.Color;

/**
 * Color util for easily setting an RGB color (alpha will be maximum)
 */
abstract RGB(Int) from Int to Int
{
	inline function new(i:Int)
	{
		this = i;
	}

	@:to
	public function toRGBA():Color
	{
		return (this << 0x08 | 0xff);
	}
}