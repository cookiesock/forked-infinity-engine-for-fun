package ui;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class CountdownSprite extends FlxSprite {
	var filePath:String = 'countdown/normal/';
	
	public function new(countdownStr:String, pixel:Bool = false)
	{
		super();

		if(pixel) {
			filePath = 'countdown/pixel/';
		}

		loadGraphic(Util.getImage(filePath + countdownStr));
		screenCenter();
		scrollFactor.set();
		
		FlxTween.tween(this, {alpha: 0}, game.PlayState.bpm / 400, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				this.destroy();
			}
		});
	}
	
	override public function update(elapsed) {
		super.update(elapsed);
	}
}
