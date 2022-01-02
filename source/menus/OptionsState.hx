package menus;

import flixel.FlxBasic;
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

	var debugText:FlxText;

	var defaultOptionsList = [
		"selectables" => [
			["Graphics", "menu", "Change how things look in menus/gameplay."],
			["Gameplay", "menu", "Change how things behave during gameplay."],
		],
		"graphics" => [
			["Back", "menu", ""],
			["Anti-Aliasing", "checkbox", "Gives extra performance when disabled at the cost of\ngraphics not looking very smooth.", "anti-aliasing"],
			["Optimization", "checkbox", "Removes all of the characters and background elements\nfor performance.", "optimization"],
			["Note Splashes", "checkbox", "When enabled, a firework-like effect will show up\nIf you hit a note and get a \"SiCK!!\" from it.", "note-splashes"],
		],
		"gameplay" => [
			["Back", "menu", ""],
			["Hitsounds", "menu", "Change what sound plays when you hit a note."],
			["Adjust Offset", "menu", "Change how early/late notes appear on-screen."],
			["Manage Keybinds", "menu", "Change the keys used to press arrows."],
			["Adjust Scroll Speed", "menu", "Change how fast your notes fall on-screen."],
			["Downscroll", "checkbox", "Makes the notes scroll downwards instead of upwards.", "downscroll"],
			["Middlescroll", "checkbox", "Makes the notes centered on-screen.", "middlescroll"],
			["Botplay", "checkbox", "When enabled, All notes will get hit for you.", "botplay"],
		],
	];

	var optionsList:Array<Dynamic> = [];
	
	var selectedOption:Int = 0;
	var descBox:FlxSprite;
	var descText:FlxText;
	var menuColor:Int = 0xFFf542d7;

    override public function create()
	{
		optionsList = defaultOptionsList["selectables"];

        menuBG = new FlxSprite().loadGraphic(Util.getImage("menuDesat"));
		menuBG.color = menuColor;
		add(menuBG);

		grpOptions = new FlxTypedGroup<AlphabetText>();
		add(grpOptions);

		checkboxGroup = new FlxTypedGroup<Checkbox>();
		add(checkboxGroup);

		reloadOptionsList();
		changeSelection();

		debugText = new FlxText(0,0,0,"",32,true);
		add(debugText);
		
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var up = FlxG.keys.justPressed.UP;
		var down = FlxG.keys.justPressed.DOWN;
		var accept = FlxG.keys.justPressed.ENTER;

		if(FlxG.keys.justPressed.BACKSPACE)
			transitionState(new MainMenuState());

		if(up) changeSelection(-1);
		if(down) changeSelection(1);

		if(accept)
		{
			switch(optionsList[selectedOption][1])
			{
				case "menu":
					switch(optionsList[selectedOption][0])
					{
						case "Back":
							optionsState = 'default';
							optionsList = defaultOptionsList["selectables"];
							reloadOptionsList(true);
							selectedOption = 0;
							changeSelection();
						case "Graphics":
							optionsState = 'graphics';
							optionsList = defaultOptionsList["graphics"];
							reloadOptionsList(true);
							selectedOption = 0;
							changeSelection();
						case "Gameplay":
							optionsState = 'gameplay';
							optionsList = defaultOptionsList["gameplay"];
							reloadOptionsList(true);
							selectedOption = 0;
							changeSelection();
						case "Adjust Offset":
							openSubState(new OffsetMenu());
						case "Manage Keybinds":
							openSubState(new KeybindMenu());
						case "Adjust Scroll Speed":
							openSubState(new ScrollSpeedMenu());
					}
				case "checkbox":
					Options.saveData(optionsList[selectedOption][3], !Options.getData(optionsList[selectedOption][3]));
					reloadShit();
			}
		}

		//debugText.text = optionsList[selectedOption][0];

		super.update(elapsed);
	}

	public function reloadOptionsList(?deleteCurrentItems:Bool = false)
	{
		if(deleteCurrentItems)
		{
			for(i in 0...grpOptions.members.length)
			{
				grpOptions.members[i].kill;
				grpOptions.members[i].destroy;
			}

			for(i in 0...checkboxGroup.members.length)
			{
				checkboxGroup.members[i].kill;
				checkboxGroup.members[i].destroy;
			}

			checkboxNumber = [];
			checkboxArray = [];

			grpOptions.clear();
			checkboxGroup.clear();
		}

		for(i in 0...optionsList.length)
		{
			var swagOption = new AlphabetText(0, 0, optionsList[i][0]);
			swagOption.isMenuItem = true;
			swagOption.targetY = i;
			swagOption.ID = i;

			var usesCheckbox:Bool = false;
			
			if(optionsList[i][1] == "checkbox")
				usesCheckbox = true;

			if(usesCheckbox) {
				swagOption.x += 300;
				swagOption.xAdd = 200;
				var checkbox:Checkbox = new Checkbox(swagOption.x - 105, swagOption.y, Options.getData(optionsList[i][3]));
				checkbox.sprTracker = swagOption;
				checkboxNumber.push(i);
				checkboxArray.push(checkbox);
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			} /*else {
				swagOption.x -= 80;
				swagOption.xAdd -= 80;
			}*/

			grpOptions.add(swagOption);
		}
	}

	public function changeSelection(?change:Int = 0)
	{
		selectedOption += change;

		if(selectedOption < 0)
			selectedOption = grpOptions.members.length - 1;

		if(selectedOption > grpOptions.members.length - 1)
			selectedOption = 0;

        for(i in 0...grpOptions.members.length)
		{
			var item = grpOptions.members[i];

			item.targetY = i - selectedOption;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));
	}

	public function reloadShit()
	{
		for(i in 0...checkboxGroup.members.length)
		{
			checkboxGroup.members[i].daValue = Options.getData(optionsList[checkboxNumber[i]][3]);
		}
	}
}
