package kiss.util;

/**
	A simple abstraction of a Rectangle
	x and y are top left and you can easily determine left, right, top, down and center 
**/
@:structInit
@:publicFields
class Rectangle
{
	var x: Float = 0;
	var y: Float = 0;
	var width: Float;
	var height: Float;

	var left(get, never): Float;

	private function get_left(): Float
	{
		return x;
	}

	var right(get, never): Float;

	private function get_right(): Float
	{
		return x + width;
	}

	var top(get, never): Float;

	private function get_top(): Float
	{
		return y;
	}

	var bottom(get, never): Float;

	private function get_bottom(): Float
	{
		return y + height;
	}

	var center_x(get, never): Float;

	private function get_center_x(): Float
	{
		return x + (width * 0.5);
	}

	var center_y(get, never): Float;

	private function get_center_y(): Float
	{
		return y + (height * 0.5);
	}

	var mid_width(get, never):Float;

	private function get_mid_width():Float {
		return width / 2;
	}

	var mid_height(get, never):Float;

	private function get_mid_height():Float {
		return height / 2;
	}

	function isOverlap(x: Float, y: Float): Bool
	{
		return left <= x && right >= x && top <= y && bottom >= y;
	}

}
