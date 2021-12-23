
package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;

// no more fnf main.hx
// yes some stuff is left in but shut yo bitch ass up i would prefer to see the fps
// note from swordcube nn

class Main extends Sprite
{
	var fpsVar:FPS;
	var framerate:Int = 60;
	
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, menus.TitleScreenState, 1, framerate, framerate, true, false));
		
		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		#end
		
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}
