package menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

class MainMenuState extends BasicState
{
	var mouseOverlapped = false;
	var mouseOverlappedBefore = false;

	var hasSelected:Bool = false;

	var menuBG:FlxSprite;
	var menuBGMagenta:FlxSprite;
	
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var selectedMenu:Int = 0;
	var menuButtons:FlxTypedGroup<FlxSprite>;
	
	var swagMenuButtons:Array<String> = ['StoryMode', 'Freeplay', 'Credits', 'Options', 'Mods'];

	override public function create()
	{
		TitleScreenState.hasAlreadyAccepted = true;
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		menuBG = new FlxSprite(-80).loadGraphic(Util.getImage('menuBG'));
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.18;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.175));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		menuBGMagenta = new FlxSprite(-80).loadGraphic(Util.getImage('menuDesat'));
		menuBGMagenta.scrollFactor.x = 0;
		menuBGMagenta.scrollFactor.y = 0.18;
		menuBGMagenta.setGraphicSize(Std.int(menuBGMagenta.width * 1.175));
		menuBGMagenta.updateHitbox();
		menuBGMagenta.screenCenter();
		menuBGMagenta.visible = false;
		menuBGMagenta.antialiasing = true;
		menuBGMagenta.color = 0xFFfd719b; // <<<<< this is here for a reason, changed the image back to menuDesat because of this
		add(menuBGMagenta);

		menuButtons = new FlxTypedGroup<FlxSprite>();
		add(menuButtons);

		for (i in 0...swagMenuButtons.length)
		{
			var menuButton:FlxSprite = new FlxSprite(0, (i * 160) + 80);
			menuButton.frames = Util.getSparrow('mainmenu/' + swagMenuButtons[i]);
			menuButton.animation.addByPrefix('super idle', "basic", 24);
			menuButton.animation.addByPrefix('selected', "white", 24);
			menuButton.animation.play('super idle');
			menuButton.ID = i;
			menuButton.screenCenter(X);
			menuButton.scrollFactor.set(0, 0);
			menuButton.antialiasing = true;
			menuButtons.add(menuButton);
		}
		changeSelection();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		FlxG.camera.follow(camFollowPos, null, 1);
	
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		
		for (i in 0...swagMenuButtons.length)
		{
			var btn:FlxSprite = menuButtons.members[i];
			btn.screenCenter(X);
		}
		if (FlxG.keys.justPressed.UP && !hasSelected) {
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN && !hasSelected) {
			changeSelection(1);
		}
		if (FlxG.keys.justPressed.ENTER)
		{
			// seriously pls use switch cases for shit like this - swordcmube
			FlxG.sound.play(Util.getSound('menus/confirmMenu'));

			hasSelected = true;

			FlxFlicker.flicker(menuBGMagenta, 1.1, 0.15, false);

			menuButtons.forEach(function(spr:FlxSprite)
				{
					if (selectedMenu != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = swagMenuButtons[selectedMenu];

							switch (daChoice)
							{
								case 'StoryMode':
									transitionState(new menus.StoryModeState());
									trace("entered story mode");
									
								case 'Freeplay':
									transitionState(new menus.FreeplayMenuState());
									trace("entered freeplay");
									
								case 'Credits':
									transitionState(new menus.CreditsState());
									trace("entered credits");

								case 'Options':
									transitionState(new menus.OptionsState());
									trace("entered options");

								case 'Mods':
									transitionState(new mods.ModsState());
									trace("entered mods");
							}
						});
					}
				});
		}
		
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			transitionState(new TitleScreenState());
		} // temporary way to go back to menus without restarting the game

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0, ?playsound = true)
	{
		selectedMenu += change;

		if (selectedMenu < 0)
			selectedMenu = swagMenuButtons.length - 1;

		if (selectedMenu > swagMenuButtons.length - 1)
			selectedMenu = 0;

		for (i in 0...menuButtons.length)
		{
			var btn:FlxSprite = menuButtons.members[i];
			btn.animation.play('super idle');
			btn.offset.y = 0;
			btn.updateHitbox();

			if (btn.ID == selectedMenu)
			{
				btn.animation.play('selected');
				btn.offset.x = 0.15 * (btn.frameWidth / 2 + 180);
				btn.offset.y = 0.15 * btn.frameHeight;
				camFollow.setPosition(btn.getGraphicMidpoint().x, btn.getGraphicMidpoint().y);
			}
		}
		
		if (playsound)
			FlxG.sound.play('assets/sounds/menus/scrollMenu' + Util.soundExt);
	}
}
