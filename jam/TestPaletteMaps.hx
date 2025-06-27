import kiss.graphics.FramebufferDisplay;
import kiss.graphics.Palette;
import kiss.graphics.PeoteView;
import lime.app.Application;
import nes.Palette;
import peote.view.Display;
import peote.view.Texture;
import peote.view.UniformFloat;

class TestPaletteMaps extends Application
{
	override function onWindowCreate()
	{
		var peoteView = new PeoteView(window);
		var uncoloredDisplay = new Display(0, 0, window.width, window.height, 0xf040f0ff);
		peoteView.addDisplay(uncoloredDisplay);

		var mix = new UniformFloat("u_mapMix", 0.0);
		var coloredDisplay = new FramebufferDisplay(peoteView, window.width, window.height);
		coloredDisplay.fbo.program.addTexture(Texture.fromData(new Palette(lospec_palette)), "palette");
		coloredDisplay.fbo.program.injectIntoFragmentShader("
			vec4 mapToPalette(int textureID, int paletteID)
			{
				vec4 indexColor = getTextureColor(textureID, vTexCoord);
				vec2 palXY = vec2(indexColor.r, 0.5);
				vec4 palColor = getTextureColor(paletteID, palXY);
				return mix(vec4(palColor.rgb, indexColor.a), indexColor, u_mapMix);
			}
		", false, [mix]);

		coloredDisplay.fbo.program.setColorFormula('mapToPalette(default_ID, palette_ID)');

		coloredDisplay.fbo.addToDisplay(uncoloredDisplay);

		var palettes = new PaletteMap();

		palettes.changeBackgroundColor(0, 1, 0x01);
		palettes.changeBackgroundColor(0, 2, 0x02);
		palettes.changeBackgroundColor(0, 3, 0x03);

		palettes.changeBackgroundColor(1, 1, 0x11);
		palettes.changeBackgroundColor(1, 2, 0x12);
		palettes.changeBackgroundColor(1, 3, 0x13);

		palettes.changeBackgroundColor(2, 1, 0x1a);
		palettes.changeBackgroundColor(2, 2, 0x2a);
		palettes.changeBackgroundColor(2, 3, 0x3a);

		palettes.changeBackgroundColor(3, 1, 0x16);
		palettes.changeBackgroundColor(3, 2, 0x26);
		palettes.changeBackgroundColor(3, 3, 0x36);

		palettes.changeSpriteColor(1, 1, 0x11);
		palettes.changeSpriteColor(1, 2, 0x21);
		palettes.changeSpriteColor(1, 3, 0x31);
		palettes.debug(uncoloredDisplay, coloredDisplay, 16);
		peoteView.zoom = 8;

		window.onKeyDown.add((code, modifier) -> switch code {
			case NUMBER_0: palettes.blacken();
			case NUMBER_1: palettes.fadeIn();
			case NUMBER_2:
			case NUMBER_3:
			case NUMBER_4:
			case NUMBER_5:
			case NUMBER_6:
			case NUMBER_7:
			case NUMBER_8:
			case NUMBER_9:
			case _: return;
		});

	}
}
