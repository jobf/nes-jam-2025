package kiss.graphics;

import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;

@:publicFields
class Quad implements Element
{
	/**
		position on x axis
	**/
	@posX public var x:Float;

	/**
		position on y axis
	**/
	@posY public var y:Float;

	/**
		width in pixels
	**/
	@varying @sizeX public var width:Int;

	/**
		height in pixels
	**/
	@varying @sizeY public var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivotX") var pivotX:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivotY") var pivotY:Float = 0.0;

	/**
		rotation in degrees
	**/
	@rotation public var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color;

	@texTile public var tile:Int = 0;

	var OPTIONS = {blend: true};

	public function new(width:Float, height:Float, tint:Color = 0xffffffFF, x:Float = 0, y:Float = 0, isCenterPivot:Bool = false)
	{
		this.width = Std.int(width);
		this.height = Std.int(height);

		this.x = Std.int(x);
		this.y = Std.int(y);

		this.tint = tint;

		if (isCenterPivot)
		{
			this.pivotX = 0.5;
			this.pivotY = 0.5;
		}
	}
}

class QuadBuffer extends Buffer<Quad>
{
	public var program(default, null):Program;

	public function new(size:Int)
	{
		super(size, size);
		program = new Program(this);
		program.snapToPixel(1);
	}

	public function addToDisplay(display:Display)
	{
		display.addProgram(program);
	}
}
