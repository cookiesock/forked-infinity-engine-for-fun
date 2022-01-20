
package;

import flixel.FlxSprite;
import ui.SimpleInfoDisplay;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	var framerate:Int = 120;

	public static var display:SimpleInfoDisplay;
	
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, menus.TitleScreenState, 1, framerate, framerate, true, false));
		
		#if !mobile
		display = new SimpleInfoDisplay(10, 3, 0xFFFFFF, "_sans");
		addChild(display);
		#end
		
		#if html5
		FlxG.autoPause = false;
		//FlxG.mouse.visible = false;
		#end
	}
}
