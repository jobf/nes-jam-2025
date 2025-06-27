package kiss.graphics;

import peote.view.Display;
import peote.view.Color;
import lime.ui.Window;

class PeoteView extends peote.view.PeoteView
{
	public var devDisplay(default, null):Display;

	public function new(window:Window, color:Color = 0x000000FF, registerEvents = true)
	{
		super(window, color, registerEvents);
		devDisplay = new Display(0, 0, window.width, window.height);
		addDisplay(devDisplay);
	}

	override function addDisplay(display:peote.view.Display, ?atDisplay:peote.view.Display = null, addBefore:Bool = false)
	{
		if(displayList.isEmpty)
		{
			// this will be the devDisplay created in constructor
			super.addDisplay(display, atDisplay, addBefore);
		}
		else if(displayList.first.value == devDisplay)
		{
			// if the devDisplay been added, add the new display before it
			super.addDisplay(display, devDisplay, true);
		}
		else
		{
			// else add the new display in front of the others or atDisplay
			super.addDisplay(display, atDisplay ?? displayList.first.value, addBefore);
		}
	}
}
