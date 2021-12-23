package menus;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class CreditsState extends BasicState{
    var menuBG:FlxSprite;
    var description:FlxText;
    var curSelected:Int;
    var credits:Array<Dynamic>;
    var creditGroup:FlxTypedGroup<FlxText>;
	override public function create()
        {
            super.create();
            //var E = new Alphabet(FlxG.width / 2, FlxG.height / 2, "TEST", true);
            //add(E);
            // fix later
            creditGroup = new FlxTypedGroup();
            curSelected = 1;
            description = new FlxText(FlxG.width / 2, FlxG.height - 100, 0, "FUCKIN", 64 );
            menuBG = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
            menuBG.scrollFactor.x = 0;
            menuBG.scrollFactor.y = 0.18;
            menuBG.setGraphicSize(Std.int(menuBG.width * 1.175));
            menuBG.updateHitbox();
            menuBG.screenCenter();
            menuBG.antialiasing = true;
            curSelected = 1;
            add(menuBG);
            var json:Dynamic = Util.getJsonContents('assets/credits/credits.json');
            credits = json.credTextShit;
            for (i in 0...credits.length) {
                //credits[i]
                var text = new FlxText(FlxG.width / 6 + i * 5, 100 + i * 70, 0, credits[i].name, 64);
                add(text);
                text.ID = i;
                creditGroup.add(text);
            }
            add(description);
            updateDesc();
        }
    
        override public function update(elapsed:Float)
        {
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.switchState(new menus.MainMenuState());
		} // temporary way to go back to menus without restarting the game
		
            super.update(elapsed);
        }
        function updateDesc() {
            description.text = credits[curSelected].desc;
        }
}
