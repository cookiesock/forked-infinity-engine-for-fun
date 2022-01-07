package;

import openfl.display.BitmapData;
import openfl.events.Event;
import mods.ModSoundUtil;
import openfl.media.Sound;
import flixel.system.FlxSound;
import mods.Mods;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import haxe.Json;

using StringTools;

// i'm actually trying to write shit myself here - swordcube
// fucking e - ZonianDX
class Util
{
	static public var soundExt:String = #if web '.mp3' #else '.ogg' #end;
	static public var funnyStringArray:Array<String> = [];

	static public function getJsonContents(path:String, ?mod:Null<String>):Dynamic {
		#if sys
		if(!Assets.exists(path))
		{
			if(sys.FileSystem.exists(Sys.getCwd() + path))
				return Json.parse(sys.io.File.getContent(Sys.getCwd() + path));

			return "File couldn't be found!";
		}
		else
		{
		#end
		if(Assets.exists(path))
			return Json.parse(Assets.getText(path));
		else 
			return null;
		#if sys
		}
		#end
	}

	static public function getSparrow(filePath:String, ?fromImagesFolder:Bool = true, ?xmlPath:String)
	{
		var png = filePath;
		var xml = xmlPath;

		if (xml == null)
			xml = png;

		if (fromImagesFolder)
		{
			png = "assets/images/" + png;
			xml = "assets/images/" + xml;
		}

		#if sys
		if(!Assets.exists(png + ".png") || !Assets.exists(xml + ".xml"))
		{
			for(mod in Mods.activeMods)
			{
				png = filePath;
		
				if (fromImagesFolder)
					png = "mods/" + mod + "/images/" + png;
				else
					png = "mods/" + mod + "/" + png;

				xml = xmlPath;

				if (xml == null)
					xml = png;
		
				if (fromImagesFolder)
					xml = "mods/" + mod + "/images/" + xml;
				else
					xml = "mods/" + mod + "/" + xml;

				trace(png);
				trace(xml);

				if(sys.FileSystem.exists(Sys.getCwd() + png + ".png") && sys.FileSystem.exists(Sys.getCwd() + xml + ".xml"))
				{
					var xmlData = sys.io.File.getContent(Sys.getCwd() + xml + ".xml");
					var bitmapData = BitmapData.fromFile(Sys.getCwd() + png + ".png");
	
					return FlxAtlasFrames.fromSparrow(bitmapData, xmlData);
				}
			}

			return FlxAtlasFrames.fromSparrow("assets/characters/images/bf/assets" + ".png", "assets/characters/images/bf/assets" + ".xml");
		}
		else
		{
		#end
		return FlxAtlasFrames.fromSparrow(png + ".png", xml + ".xml");
		#if sys
		}
		#end
	}

    // SPIRIT FUCKING CRASHES THE GAME IF THIS IS REMOVED, EITHER RE-EXPORT HIM AS AN XML
    // OR LEAVE HIM AS IS NOW, OTHERWISE THE GAME WILL CRASH
	// fuck you

	static public function getImage(filePath:String, ?fromImagesFolder:Bool = true)
	// this is so i can grab images without having to rembr that i have to put a .png at the end
	// - swordcube
	{
		var png = filePath;
		
		if (fromImagesFolder)
			png = "assets/images/" + png;
		else
			png = "assets/" + png;

		#if sys
		if(!Assets.exists(png + ".png", IMAGE))
		{
			trace("remember, a mod loaded image is coming so be prepared!!! :D");

			for(mod in Mods.activeMods)
			{
				png = filePath;
		
				if (fromImagesFolder)
					png = "mods/" + mod + "/images/" + png;
				else
					png = "mods/" + mod + "/" + png;

				if(sys.FileSystem.exists(Sys.getCwd() + png + ".png"))
					return png + ".png";
			}

			return "oof.png";
		}
		else
		{
		#end
		return png + '.png';
		#if sys
		}
		#end
	}

	static public function getSound(filePath:String, ?fromSoundsFolder:Bool = true, ?useUrOwnFolderLmfao:Bool = false)
	{
		var base:String = "assets/";

		if(!useUrOwnFolderLmfao)
		{
			if(fromSoundsFolder)
				base += "sounds/";
			else
				base += "music/";
		}

		return base + filePath + soundExt;
	}

	// haha leather goes coding---

	static public function getInst(songName:String) {
		return getSound("songs/" + songName.toLowerCase() + "/Inst", false, true);
	}

	static public function getVoices(songName:String) {
		return getSound("songs/" + songName.toLowerCase() + "/Voices", false, true);
	}

	static public function getCharacterIcons(charName:String, ?haveAssetsLol:Bool = false)
	{
		return (haveAssetsLol ? "assets/" : "") + 'characters/images/$charName/icons';
	}

	static public function getJsonPath(path:String)
	{
		return "assets/" + path + ".json";
	}

	/*static public function getSongPath(songPath:String) {
		return songPath.toLowerCase().replace(' ', '-');
	}*/ // bruh

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;

		if(newValue < min)
			newValue = min;
		else if(newValue > max)
			newValue = max;
		
		return newValue;
	}

	public static function mouseOverlappingSprite(spr:FlxSprite) {
		if (FlxG.mouse.x > spr.x && FlxG.mouse.x < spr.x+spr.width && FlxG.mouse.y > spr.y && FlxG.mouse.y < spr.y+spr.height)
			return true;
		else
			return false;
	}

	
	public static function loadModSound(path:String, ?autoPlay:Bool = false, ?persist:Bool = false):FlxSound
	{
		#if sys
		var modFoundFirst:String = "";

		for(mod in Mods.activeMods)
		{
			if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/' + path + soundExt))
				modFoundFirst = mod;
		}

		if(modFoundFirst != "")
		{
			var sound = new ModSoundUtil().loadCoolModdedSound('mods/$modFoundFirst/' + path + soundExt);

			sound.persist = persist;

			if(autoPlay)
				sound.play();

			sound.active = true;

			return sound;
		}
		#end

		return new FlxSound();
	}
}

class LOG {
	// do this shit later
		//static public function log(log:String) {
			//trace("logging "+ "log" + " to screen" );
			//var logText
		//}
}
