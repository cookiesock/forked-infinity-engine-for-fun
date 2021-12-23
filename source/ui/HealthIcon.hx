package ui;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	private var char:String = '';
	private var isPlayer:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function changeIcon(char:String) {
		if(this.char != char) {	
			var file:Dynamic = Util.getImage('assets/characters/images/' + char + '/icons', false);	
			loadGraphic(file, true, 150, 150);
			updateHitbox();
			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = true;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}
}
