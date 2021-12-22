import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class CreditsState extends FlxState{
    var menuBG:FlxSprite;
    var Description:FlxText;
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
            Description = new FlxText(FlxG.width / 2, FlxG.height - 100, 0, "FUCKIN", 64 );
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
                var Text = new FlxText(FlxG.width / 6 + i * 5, 100 + i * 70, 0, credits[i].name, 64);
                add(Text);
                Text.ID = i;
                creditGroup.add(Text);
            }
            add(Description);
            updateDesc();
        }
    
        override public function update(elapsed:Float)
        {
            super.update(elapsed);
        }
        function updateDesc() {
            Description.text = credits[curSelected].desc;
        }
}