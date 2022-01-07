package menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

using StringTools;

class FPSCapMenu extends BasicSubState
{
	var bg:FlxSprite;
	var scrollSpeedWarning:FlxText;
	var funnyScrollSpeed:FlxText;
	var holdTime:Float = 0;
	var stupidDumb:Float = 0;

	var leftP:Bool = false;
	var left:Bool = false;
	var rightP:Bool = false;
	var right:Bool = false;
	var accept:Bool = false;

	var maxSpeed:Int = 1000;

	override public function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		funnyScrollSpeed = new FlxText(0, 0, 0, "placeholder", 64);
		funnyScrollSpeed.setFormat("assets/fonts/vcr.ttf", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyScrollSpeed.scrollFactor.set();
		funnyScrollSpeed.screenCenter();
		funnyScrollSpeed.borderSize = 2.4;
		add(funnyScrollSpeed);

		scrollSpeedWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press LEFT & RIGHT to change FPS Cap.", 32);
		scrollSpeedWarning.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollSpeedWarning.scrollFactor.set();
		scrollSpeedWarning.screenCenter(X);
		scrollSpeedWarning.borderSize = 2.4;
		add(scrollSpeedWarning);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		leftP = FlxG.keys.justPressed.LEFT;
		left = FlxG.keys.pressed.LEFT;
		rightP = FlxG.keys.justPressed.RIGHT;
		right = FlxG.keys.pressed.RIGHT;
		accept = FlxG.keys.justPressed.ENTER;

		if(FlxG.keys.justPressed.BACKSPACE)
			close();

		if(left || right) {
			var daMultiplier:Int = left ? -10 : 10;
			changeOffset(daMultiplier / 10);
		} else {
			holdTime = 0;
		}

		funnyScrollSpeed.text = "Current FPS Cap: " + Std.int(Options.getData('fpsCap'));
		funnyScrollSpeed.screenCenter();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		stupidDumb = elapsed;

		super.update(elapsed);
	}

	public function changeOffset(?change:Float = 0)
	{
		holdTime += stupidDumb;

		if(holdTime > 0.5 || leftP || rightP)
		{
			var speed:Float = Options.getData('fpsCap');
			speed += change;

			if(speed < 10)
				speed = 10;

			if(speed > maxSpeed)
				speed = maxSpeed;

			Options.saveData('fpsCap', speed);
		}
	}
}