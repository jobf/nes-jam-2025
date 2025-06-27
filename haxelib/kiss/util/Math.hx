package kiss.util;

/** linear interpolation **/
inline function lerp(a:Float, b:Float, t:Float):Float
{
	return a + (b - a) * t;
}

function toPixelsPerFrame(pixelsPerSecond:Int):Float
{
	return pixelsPerSecond / App.framesPerSecond;
}

function msToFrames(milliseconds:Int):Int
{
	return Std.int((milliseconds / 1000) * App.framesPerSecond);
}

function framesToMs(frames:Int):Int
{
	return Std.int(frames / App.framesPerSecond) * 1000;
}

/**
	distance between 2 points 
**/
inline function distance_to_point(x_a:Float, y_a:Float, x_b:Float, y_b:Float):Float
{
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;
	return Math.sqrt(x_d * x_d + y_d * y_d);
}

function random_range(?min:Float = -1, ?max:Float = 1):Float
	return min + Math.random() * (max - min);

function random_range_int(?min:Float = -1, ?max:Float = 1):Int
	return Std.int(random_range(min, max));

/**
 * produce an array of integers
 * @param start the first value in the array
 * @param end theg final value in the array
 * @return Array<Int>
 */
inline function range(start:Int, end:Int):Array<Int>
{
	if(start > end) return range_reverse(start, end);

	return [for (n in start...end + 1) n];
}

/**
 * produce an array of integers, when start is a higher value than end
 * @param start the first value in the array
 * @param end theg final value in the array
 * @return Array<Int>
 */
inline function range_reverse(start:Int, end:Int):Array<Int>
{
	var integers:Array<Int> = [];
	while (end > start)
	{
		integers.push(end);
		end--;
	}
	return integers;
}

class ValueExtensions
{
	public static inline function round_to(value:Float, multiple:Int):Int
	{
		return Math.ceil(value / multiple) * multiple;
	}

	/**
	 * Wraps a value between 0 and another number, works in positive and negative directions
	 * @param value the value to be wrapped
	 * @param lessThan result will be kept below this number
	 * @return Int
	 */
	public static inline function wrap(value:Int, lessThan:Int):Int
	{
		return (value % lessThan + lessThan) % lessThan;
	}
}


@:publicFields
class Grid2d
{
	static inline function column(column_count:Int, index:Int):Int {
		return Std.int(index % column_count);
	}
	
	static inline function row(column_count:Int, index:Int):Int {
		return Std.int(index / column_count);
	}
	
	static inline function index(column_count:Int, column:Int, row:Int):Int {
		return column + column_count * row;
	}
}