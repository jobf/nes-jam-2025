package kiss;

import kiss.graphics.Quad;
import kiss.graphics.Quad.QuadBuffer;
import kiss.graphics.RGB;
import peote.view.Color;
import peote.view.Display;
import peote.view.text.Text;
import peote.view.text.TextOptions;
import peote.view.text.TextProgram;

using kiss.util.Math.Grid2d;

class DevConsole
{
	public var display(default, null):Display;

	var lines:TextProgram;
	var textOptions:TextOptions;
	var labels:Array<Label> = [];
	var labelsLeft = 8;
	var labelsTop = 8;
	var labelCount = 0;
	var lineHeight:Int;
	var watchers:Array<() -> Void> = [];

	public function new(display:Display)
	{
		this.display = display;

		var textColor:RGB = 0xfe9e5e;
		textOptions = {
			fgColor: textColor,
			letterWidth: 8,
			letterHeight: 8,
		}
		lineHeight = textOptions.letterHeight + 2;

		lines = new TextProgram(textOptions);
		lines.addToDisplay(display);

		display.hide();
		display.peoteView.window.onKeyDown.add((code, modifier) -> if (code == F2) toggleVisibility());
	}

	function toggleVisibility()
	{
		if (display.isVisible)
		{
			display.hide();
		}
		else
		{
			trace('show debug');
			display.show();
		}
	}

	public function getLabel(text:String = "_"):Text
	{
		var label = new Text(labelsLeft, labelsTop + (lineHeight * labelCount), text);
		labelCount++;
		return lines.add(label);
	}

	public function addLabel(refresh:() -> String)
	{
		labels.push(new Label(getLabel(refresh()), refresh));
	}

	public function update()
	{
		for (label in labels)
		{
			label.update();
		}
		lines.updateAll();
		for (w in watchers)
		{
			w();
		}
	}

	public function addTilemap(tilesInRow:Int, tilesInColumn:Int, tileSize:Int, getCollision:(column:Int, row:Int) -> Int, colors:Map<Int, Color>)
	{
		var numTiles = tilesInRow * tilesInColumn;
		var tileMap = new QuadBuffer(numTiles);
		tileMap.addToDisplay(display);
		for (r in 0...tilesInColumn)
		{
			for (c in 0...tilesInRow)
			{
				var x:Float = c * tileSize;
				var y:Float = r * tileSize;
				tileMap.addElement(new Quad(tileSize, tileSize, x, y,));
			}
		}

		watchers.push(() -> for (r in 0...tilesInColumn)
		{
			for (c in 0...tilesInRow)
			{
				var collision = getCollision(c, r);
				var i = tilesInRow.index(c, r);
				var tile = tileMap.getElement(i);
				tile.tint = colors[collision];
				// tile.tint.a = 0x30;
				tileMap.updateElement(tile);
			}
		});
	}
}

class Label
{
	var text:Text;
	var refresh:() -> String;

	public function new(text:Text, refresh:() -> String)
	{
		this.text = text;
		this.refresh = refresh;
	}

	public function update()
	{
		text.text = refresh();
	}
}
