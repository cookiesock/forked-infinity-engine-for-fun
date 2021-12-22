package;

import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

// i'm actually trying to write shit myself here - swordcube
// fucking e - ZonianDX
class Util
{
	static public var soundExt:String = #if web '.mp3' #else '.ogg' #end;
	static public function getJsonContents(path:String) {
		return Json.parse(Assets.getText(path));
	}
	static public function getSparrow(filePath:String, ?fromImagesFolder:Bool = true, ?xmlPath:String)
	{
		var png = filePath;
		var xml = xmlPath;
		if (xml == null)
		{
			xml = png;
		}
		if (fromImagesFolder)
		{
			png = "assets/images/" + png;
			xml = "assets/images/" + xml;
		}

		return FlxAtlasFrames.fromSparrow(png + ".png", xml + ".xml");
	}
	/*static public function getSongPath(songPath:String) {
		return songPath.toLowerCase().replace(' ', '-');
	}*/ // bruh
}
class LOG {
	// do this shit later
		//static public function log(log:String) {
			//trace("logging "+ "log" + " to screen" );
			//var logText
		//}
}
