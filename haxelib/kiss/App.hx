package kiss;

import haxe.CallStack;
import kiss.graphics.PeoteView;
import lime.app.Application;
import lime.system.System;

abstract class App extends Application
{
	var peoteView:PeoteView;
	var console:DevConsole;
	var resWidth:Int;
	var resHeight:Int;

	public static var framesPerSecond:Int = 0;

	var frameDurationMs:Int = 0;
	var accumulatorMax:Int = 0;
	var appTimeMs:Int = 0;
	var elapsedMs:Int = 0;
	var totalMs:Int = 0;
	var accumulator:Int = 0;

	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					peoteView = new PeoteView(window);
					console = new DevConsole(peoteView.devDisplay);

					var width = Std.parseInt(haxe.macro.Compiler.getDefine("resWidth"));
					resWidth = width > 0 ? width : window.width;
					var height = Std.parseInt(haxe.macro.Compiler.getDefine("resHeight"));
					resHeight = height > 0 ? height : window.height;

					window.onResize.add(fitToWindow);

					framesPerSecond = 30;
					frameDurationMs = Std.int((1 / framesPerSecond) * 1000);
					accumulatorMax = Std.int(2000 / frameDurationMs - 1);
				}
				catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	override function onPreloadComplete()
	{
		init();
		fitToWindow(window.width, window.height);
	}

	override function update(deltaTime:Int)
	{
		appTimeMs = System.getTimer();
		elapsedMs = appTimeMs - totalMs;
		totalMs = appTimeMs;
		accumulator += elapsedMs;
		if (accumulator > accumulatorMax)
		{
			accumulator = frameDurationMs;
		}

		while (accumulator >= frameDurationMs)
		{
			stepFixed();
			accumulator -= frameDurationMs;
		}

		stepDynamic(deltaTime);

		draw(accumulator / frameDurationMs);

		console.update();
	}

	function fitToWindow(windowWidth:Int, windowHeight:Int):Void
	{
		// determine scale factors for x and y
		// round down to nearest 2 to keep the pixels square
		var scaleX = Math.floor((windowWidth / resWidth) / 2) * 2;
		var scaleY = Math.floor((windowHeight / resHeight) / 2) * 2;

		// we want the smallest scale factor to ensure the view stays inside the window
		var scale = Math.min(scaleX, scaleY);

		// scale peoteView
		peoteView.zoom = scale;

		// offset the displays to keep in the center of window
		var offsetX = Std.int(((windowWidth / scale) / 2) - (resWidth / 2));
		var offsetY = Std.int(((windowHeight / scale) / 2) - (resHeight / 2));

		@:privateAccess
		for (display in peoteView.displayList)
		{
			display.x = offsetX;
			display.y = offsetY;
		}
	}

	abstract function init():Void;

	abstract function stepFixed():Void;

	abstract function stepDynamic(elapsedMs:Int):Void;

	abstract function draw(t:Float):Void;
}
