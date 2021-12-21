package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxSprite;
import flash.media.Sound;

using StringTools;

// i'm actually trying to write shit myself here - swordcube

class SwagUtilShit {

	static public var soundExt:String = 'mp3'; // THIS IS HERE SO YOU CAN CHANGE IT LOL
	// IDK IF MP3 WORKS ON DESKTOP BUT THERE'S NO REASON IT SHOULDN'T

	static public function getSound(filePath:String, fileName:String)
	{	
		var grabbedSound:String = filePath + fileName;
		return grabbedSound;
		// ok so turns out the menu music straight up doesn't fucking play
	}
	
	static public function getSparrow(filePath:String, fileName:String)
	{
		var png:String = filePath + fileName + '.png';
		var xml:String = filePath + fileName + '.xml';
		
		return FlxAtlasFrames.fromSparrow(png, xml);
		
		// I TRIED TO DO THIS MYSELF OK
	}

	static public function getPacker(filePath:String, fileName:String)
	{
		var png:String = filePath + fileName + '.png';
		var txt:String = filePath + fileName + '.txt';
		
		return FlxAtlasFrames.fromSpriteSheetPacker(png, txt);
		
		// I ALSO TRIED TO DO THIS MYSELF OK
	}
	
	static public function getSongPath(songPath:String) {
		return songPath.toLowerCase().replace(' ', '-');
	}
}
