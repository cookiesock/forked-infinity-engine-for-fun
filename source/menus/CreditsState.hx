package menus;

import ui.Icon;
import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;

class CreditsState extends BasicState{
    var menuBG:FlxSprite;
    var description:FlxText;
    var curSelected:Int;
    var credits:Array<Dynamic>;
    var creditGroup:FlxTypedGroup<AlphabetText>;
    var creditIconGroup:FlxTypedGroup<Icon>;

	override public function create()
        {
            super.create();

            creditGroup = new FlxTypedGroup();
            creditIconGroup = new FlxTypedGroup();
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
                var text = new AlphabetText(FlxG.width / 6 + i * 5, 100 + i * 150, true, credits[i].name);
                text.ID = i;
                add(text);
                creditGroup.add(text);

                var icon = new Icon("credits/icons/" + credits[i].icon, creditGroup.members[i], false, 10, -30, LEFT);
                icon.ID = i;
                add(icon);
                creditIconGroup.add(icon);
            }

            add(description);
            updateDesc(0);
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
            }

            if(FlxG.keys.justPressed.UP)
            {
                curSelected -= 1;

                if(curSelected < 0)
                    curSelected = credits.length - 1;
            }
		
            updateDesc(elapsed);
            super.update(elapsed);
        }

        function updateDesc(elapsed:Float) {
            var funnyLerpValue = 0.08 / (Main.display.currentFPS / 60);

            for(credit in 0...creditGroup.members.length) {
                if(credit == curSelected)
                {
                    creditGroup.members[credit].x = FlxMath.lerp(creditGroup.members[credit].x, FlxG.width / 6 + credit * 5 + 96, funnyLerpValue);
                    creditGroup.members[credit].alpha = 1;
                    creditIconGroup.members[credit].alpha = 1;
                }
                else
                {
                    creditGroup.members[credit].x = FlxMath.lerp(creditGroup.members[credit].x, FlxG.width / 6 + credit * 5, funnyLerpValue);
                    creditGroup.members[credit].alpha = 0.6;
                    creditIconGroup.members[credit].alpha = 0.6;
                }
            }

            if(credits[curSelected].desc != null)
            { 
                if(description != null) // cleanup stuff
                {
                    remove(description);
                    description.kill();
                    description.destroy();
                }
    
                description = new FlxText(0,0,FlxG.width,credits[curSelected].desc, 24, true);
                description.setFormat("assets/fonts/funkin.otf", 64, FlxColor.BLACK, RIGHT);
                description.y = FlxG.height - description.height - 30;
                add(description);
            }
        }
}
