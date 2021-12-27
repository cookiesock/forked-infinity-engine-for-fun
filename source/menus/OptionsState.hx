package menus;

import haxe.ds.Option;
import flixel.FlxSubState;
import flixel.text.FlxText;
import ui.AlphabetText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

class OptionsState extends BasicState
{
	var menuBG:FlxSprite;
	var grpOptions:FlxTypedGroup<AlphabetText>;

	var checkboxGroup:FlxTypedGroup<Checkbox>;
	var checkboxNumber:Array<Int> = [];
	var checkboxArray:Array<Checkbox> = [];

	var optionsState:String = "default";

	var defaultOptionsList:Array<Dynamic> = [
		["Graphics Options", "Change graphics settings such as Anti-Aliasing, Low Quality, etc."],
		["Gameplay Options", "Change gameplay settings such as Downscroll or Middlescroll to play better."],
		["Manage Keybinds", "Manage your controls for menus and gameplay."],
		["Note Colors", "Change the color of your notes, personalize them to your liking!"],
		["Note Skin", "Change how your notes look during gameplay."],
		["UI Skin", "Change how things such as the combo and ratings look during gameplay."],
	];

	var graphicsOptionsList:Array<Dynamic> = [
		["Toggle Background", "When disabled, The background will disappear entirely.", "checkbox"],
		["Low Quality", "Removes some background elements for performance when enabled.", "checkbox"],
		["Anti-Aliasing", "Gives more performance when disabled, at the cost of lower quality graphics.", "checkbox"],
		["Remove Characters", "When enabled, every character will get removed for performance.", "checkbox"], // max is 1
	];

	var gameplayOptionsList:Array<Dynamic> = [
		["Downscroll", "Makes notes scroll down instead of up.", "checkbox","downscroll"],
		["Botplay", "Enables bot to play the song for you!", "checkbox","botplay"],
		["Adjust Offset", "Change how early/late your notes fall on-screen.","menushit","songOffset"]
	];

	var optionsList:Array<Dynamic> = [];
	var selectedOption:Int = 0;
	var descBox:FlxSprite;
	var descText:FlxText;
	var menuColor:Int = 0xFFe83aa2;

    override public function create()
	{
        menuBG = new FlxSprite().loadGraphic(Util.getImage("menuDesat"));
		add(menuBG);

		menuBG.color = menuColor;

		grpOptions = new FlxTypedGroup<AlphabetText>();
		add(grpOptions);

		checkboxGroup = new FlxTypedGroup<Checkbox>();
		add(checkboxGroup);

		optionsList = defaultOptionsList; // set options to default

		descBox = new FlxSprite(0, FlxG.height * 0.98).makeGraphic(FlxG.width, 999, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(0, 0, 0, "This should never be seen.", 22);
		descText.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.screenCenter(X);
		descText.borderSize = 2.4;
		descText.alpha = 0;
		add(descText);

		refreshOptionsList();

		changeSelection();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		var up = FlxG.keys.justPressed.UP;
		var down = FlxG.keys.justPressed.DOWN;
		var accept = FlxG.keys.justPressed.ENTER;

		if(up) changeSelection(-1);
		if(down) changeSelection(1);

		if(FlxG.keys.justPressed.BACKSPACE)
		{
			Options.saveSettings();
			switch(optionsState)
			{
				default:
					optionsState = "default";
					optionsList = defaultOptionsList;

					refreshOptionsList(true);
					selectedOption = 0;
					changeSelection();
				case 'default':
					FlxG.switchState(new MainMenuState());
			}
		}

		if(accept) {
			switch(optionsState)
			{
				default:
					var daOption:String = optionsList[selectedOption][0];

					switch(daOption)
					{
						case 'Graphics Options':
							optionsState = "graphicsOptions";
							optionsList = graphicsOptionsList;

							refreshOptionsList(true);
							selectedOption = 0;
							changeSelection();

							//openSubState(new whateversubstatehahaha());
						case 'Gameplay Options':
							optionsState = "gameplayOptions";
							optionsList = gameplayOptionsList;

							refreshOptionsList(true);
							selectedOption = 0;
							changeSelection();
					}
				
				case 'graphicsOptions':
					Options.graphicsSettings[selectedOption] = !Options.graphicsSettings[selectedOption];
					reloadShit();

				case 'gameplayOptions':
					if(gameplayOptionsList[selectedOption][2] == "checkbox")
						Reflect.setProperty(Options, gameplayOptionsList[selectedOption][3], !Reflect.getProperty(Options, gameplayOptionsList[selectedOption][3]));

					reloadShit();
			}
		}

		if(descBox != null) {
			descBox.y = FlxMath.lerp(descBox.y, FlxG.height * 0.9, Math.max(0, Math.min(1, elapsed * 3)));
		}

		if(descText != null) {
			descText.screenCenter(X);
			descText.text = optionsList[selectedOption][1];
			descText.alpha = FlxMath.lerp(descText.alpha, 1, Math.max(0, Math.min(1, elapsed * 3)));
			if(descBox != null) {
				descText.y = descBox.y + 25;
			}
		}

		super.update(elapsed);
	}

	public function refreshOptionsList(?deletePreviousList:Bool = false)
	{
		if(deletePreviousList)
		{
			for(i in 0...checkboxGroup.members.length)
			{
				checkboxGroup.members[i].kill();
				checkboxGroup.members[i].destroy();
			}

			for(i in 0...grpOptions.members.length)
			{
				grpOptions.members[i].kill();
				grpOptions.members[i].destroy();
			}

			checkboxNumber = [];
			checkboxArray = [];

			grpOptions.clear();
			checkboxGroup.clear();
		}

		for(i in 0...optionsList.length)
		{
			var alphabet = new AlphabetText(0, 0, optionsList[i][0]);
            alphabet.targetY = i;
            alphabet.isMenuItem = true;

			var isCheckbox:Bool = false;
			if(optionsList[i][2] == 'checkbox')
				isCheckbox = true;

			if(isCheckbox)
			{
				alphabet.x += 300;
				alphabet.xAdd = 200;

				var checkbox:Checkbox = new Checkbox(alphabet.x - 105, alphabet.y, Options.graphicsSettings[i]);
				checkbox.sprTracker = alphabet;
				checkboxNumber.push(i);
				checkboxArray.push(checkbox);
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}

            grpOptions.add(alphabet);

			reloadShit();
		}
	}

	function changeSelection(change:Int = 0)
	{
		selectedOption += change;

		if(selectedOption < 0)
			selectedOption = optionsList.length - 1;

		if(selectedOption > optionsList.length - 1)
			selectedOption = 0;

        for(i in 0...grpOptions.members.length)
			{
				var item = grpOptions.members[i];
	
				item.targetY = i - selectedOption;
	
				item.alpha = 0.6;
	
				if (item.targetY == 0)
					item.alpha = 1;
			}

		FlxG.sound.play(Util.getSound('menus/scrollMenu', true));
	}

	function reloadShit()
	{
		for (i in 0...checkboxArray.length) {
			var checkbox:Checkbox = checkboxArray[i];

			if(checkbox != null) {
				var daValue = false;

				switch(optionsState)
				{
					case "graphicsOptions":
						daValue = Options.graphicsSettings[checkboxNumber[i]];
					case "gameplayOptions":
						daValue = Reflect.getProperty(Options, gameplayOptionsList[i][3]);
				}

				checkboxGroup.members[i].daValue = daValue;
			}
		}
	}
}
