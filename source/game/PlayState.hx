package game;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import lime.utils.Assets;
import openfl.Assets;

class PlayState extends BasicState
{
	var singAnims = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	//var stage:Stage;
	var testChar:Character;
	var testChar2:Character;
	var debugText:FlxText;
	override public function create()
	{
		funkyBpm(100);

		//add(stage);
		//stage = new Stage('stage');

		debugText = new FlxText(0,0,FlxG.width, "", 12, true);
		debugText.color = FlxColor.WHITE;
		add(debugText);
		testChar2 = new Character(100, 120, "gf");
		testChar2.screenCenter();
		add(testChar2);
		testChar = new Character(testChar2.x+300, testChar2.y+100, "bf");
		add(testChar);
		super.create();
	}

	override public function update(elapsed:Float)
	{
		debugText.text = curBeat + "\n" + curStep;
		super.update(elapsed);
	}

	override public function beatHit(timer:FlxTimer)
	{
		testChar.dance();
		testChar2.dance();
		super.beatHit(timer);
	}
}