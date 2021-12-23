package menus;

import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class CreditsState extends BasicState{
    var menuBG:FlxSprite;
    var description:AlphabetText;
    var curSelected:Int;
    var credits:Array<Dynamic>;
    var creditGroup:FlxTypedGroup<AlphabetText>;

	override public function create()
        {
            super.create();

            creditGroup = new FlxTypedGroup();
            curSelected = 0;

            menuBG = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
            menuBG.scrollFactor.x = 0;
            menuBG.scrollFactor.y = 0.18;
            menuBG.setGraphicSize(Std.int(menuBG.width * 1.175));
            menuBG.updateHitbox();
            menuBG.screenCenter();
            menuBG.antialiasing = true;

            curSelected = 0;
            add(menuBG);

            var json:Dynamic = Util.getJsonContents('assets/credits/credits.json');
            credits = json.credTextShit;

            for (i in 0...credits.length) {
                var text = new AlphabetText(FlxG.width / 6 + i * 5, 100 + i * 70, true, credits[i].name);
                text.ID = i;
                add(text);

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

            if(FlxG.keys.justPressed.ENTER)
            {
                Util.openURL(credits[curSelected].link);
            }

            if(FlxG.keys.justPressed.DOWN)
            {
                curSelected += 1;

                if(curSelected > credits.length - 1)
                    curSelected = 0;

                updateDesc();
            }

            if(FlxG.keys.justPressed.UP)
            {
                curSelected -= 1;

                if(curSelected < 0)
                    curSelected = credits.length - 1;

                updateDesc();
            }
		
            super.update(elapsed);
        }

        function updateDesc() {
            for(credit in creditGroup) {
                if(credit.ID == curSelected)
                {
                    credit.x = FlxG.width / 6 + credit.ID * 5 + 32;
                    credit.alpha = 1;
                }
                else
                {
                    credit.x = FlxG.width / 6 + credit.ID * 5;
                    credit.alpha = 0.6;
                }
            }

            if(credits[curSelected].desc != null)
            {
                trace(credits[curSelected].desc);
                
                if(description != null) // cleanup stuff
                {
                    remove(description);
                    description.kill();
                    description.destroy();
                }
    
                description = new AlphabetText(0,0,false,credits[curSelected].desc);
                description.x = FlxG.width - description.width - 8;
                description.y = FlxG.height - description.height - 30;
                add(description);
            }
        }
}
