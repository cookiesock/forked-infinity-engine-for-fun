package;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class MainMenuState extends FlxState
{
	var menuBG:FlxSprite;
	var menuBGMagenta:FlxSprite;
	var camFollow:FlxObject; // yaal forgir this shit lmao - ZonianDX

	var selectedMenu:Int = 0;
	var menuButtons:FlxTypedGroup<FlxSprite>;
	
	var swagMenuButtons:Array<String> = ['StoryMode', 'Freeplay', 'Credits', 'Options',];

	override public function create()
	{
		// THE GAME LITERALLY CAN'T FIND SHIT FROM THE ASSETS FOLDER HELP
		// IT ONLY WORKS WITH SPARROW SHIT HEBSiuhbvjgdsh
		camFollow = new FlxObject();
		add(camFollow);
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.NO_DEAD_ZONE, 9);
		menuBG = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.18;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.175));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		menuBGMagenta = new FlxSprite(-80).loadGraphic('assets/images/menuBGMagenta.png');
		menuBGMagenta.scrollFactor.x = 0;
		menuBGMagenta.scrollFactor.y = 0.18;
		menuBGMagenta.setGraphicSize(Std.int(menuBGMagenta.width * 1.175));
		menuBGMagenta.updateHitbox();
		menuBGMagenta.screenCenter();
		menuBGMagenta.visible = false;
		menuBGMagenta.antialiasing = true;
		menuBGMagenta.color = 0xFFfd719b;
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
		super.create();
		camFollow.screenCenter();
	}

	override public function update(elapsed:Float)
	{
		for (i in 0...swagMenuButtons.length)
		{
			var btn:FlxSprite = menuButtons.members[i];
			btn.screenCenter(X);
		}
		if (FlxG.keys.justPressed.UP) {
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN) {
			changeSelection(1);
		}
		if (FlxG.keys.justPressed.ENTER)
		{
			// dont use if statements when using multiple values - ZonianDX
			//if (swagMenuButtons[selectedMenu] == "StoryMode") {
				//FlxG.switchState(new PlayState());
			//}
			switch swagMenuButtons[selectedMenu]{
				case "StoryMode":
					FlxG.switchState(new PlayState());
				case "Credits":
					FlxG.switchState(new CreditsState());
			}
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
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
				camFollow.setPosition(btn.x, btn.y);
			}
		}
	}
}
