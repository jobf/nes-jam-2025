import nes.Tiles;
import kiss.util.Math;
import peote.view.text.Text;
using kiss.util.Math.ValueExtensions;

class Tutorial
{
	var text:Text;
	var sprite:Sprite;
	var duration:Int = 0;
	var remaining:Int = 0;
	var buttons:Array<Button> = [NONE];
	var index:Int = 0;
	var messages:Array<String> = [];

	public var isEnabled:Bool = false;

	public function new(text:Text)
	{
		this.text = text;

		duration = msToFrames(200);
		remaining = duration;
		index = 0;
	}

	public function update()
	{
		if (!isEnabled)
			return;

		if (remaining > 0)
		{
			remaining--;
		}
		else
		{
			remaining = duration;
			showMessage();
		}
	}

	public function showIntro(sprite:Sprite)
	{
		trace('showIntro');
		this.sprite = sprite;
		buttons = [LEFT, LEFT, LEFT, RIGHT, RIGHT, RIGHT, A, A, A,];
		this.sprite.changeTile(NONE);
	}

	public function move(x:Int, y:Int)
	{
		sprite.move(x, y);
	}

	public function press(button:Button)
	{
		if (!isEnabled)
			return;
		this.sprite.changeTile(button);
	}

	public function release(button:Button)
	{
		if (!isEnabled)
			return;
		this.sprite.changeTile(NONE);
	}

	public function setMessages(messages:Array<String>)
	{
		if (!isEnabled)
			return;
		this.messages = messages;
		index = 0;
		showMessage();
	}

	function showMessage()
	{
		if (!isEnabled)
			return;
		if (messages.length > 0)
		{
			text.text = parseMessage(messages[index]);
			var width = text.text.length * 8;
			text.x = Std.int(128 - (width / 2));
			text.y = sprite.tile.y + 16;
			index = (index + 1).wrap(this.messages.length);
			// trace(text.text);
		}
	}

	function parseMessage(s:String):String
	{
		if(s == null) return "";
		
		var parts = s.split(":");
		duration = msToFrames(Std.parseInt(parts[0]));
		remaining = duration;
		return parts[1];
	}

	public function clearMessages()
	{
		messages = [];
		text.text = "";
	}
}

enum abstract Button(Int) to Int
{
	// var HIDDEN = 0;
	var NONE = 88;
	var LEFT = 89;
	var RIGHT = 90;
	var B = 91;
	var A = 92;
}
