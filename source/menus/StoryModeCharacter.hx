package menus;

import haxe.Json;
import mods.Mods;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class StoryModeCharacter extends FlxSprite {
    public var name = "bf";
    public var idleAnim = "";
    public var confirmAnim = "";
    public var json:Dynamic;
    public var anims:Array<Dynamic> = [];
    public var position:Array<Int> = [0,0];
    public var isPlayer:Bool = false;
    public var origX:Float = 0;
    public var origY:Float = 0;

    public function new(x, y, name, ?isPlayer:Bool)
    {
        super(x, y);

        this.name = name;
        this.isPlayer = isPlayer;
        origX = x;
        origY = y;

        changeChar(name);
    }

    override public function update(elapsed) {
        super.update(elapsed);
    }

    public function changeChar(?name:String = "bf", ?removePreviousShit:Bool = false)
    {
        if(name == null || name == "")
        {
            visible = false;
        }
        else
        {
            visible = true;
            #if sys
            if(Assets.exists('assets/storymode/$name.json'))
            #end
                json = Util.getJsonContents('assets/storymode/$name.json');
            #if sys
            else
            {
                if(Mods.activeMods.length > 0)
                {
                    for(mod in Mods.activeMods)
                    {
                        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/storymode/$name.json'))
                        {
                            json = Util.getJsonContents('mods/$mod/storymode/$name.json');
                        }
                    }
                }
            }
            #end

            #if sys
            if(Assets.exists('assets/storymode/images/$name/assets.png', IMAGE))
            #end
                frames = Util.getSparrow('assets/storymode/images/$name/assets', false);
            #if sys
            else
                frames = Util.getSparrow('storymode/images/$name/assets', false);
            #end

            //if(json.scale != 1) {
                setGraphicSize(Std.int(width * json.scale));
                updateHitbox();
            //}

            antialiasing = Options.getData('anti-aliasing');
            position = json.position;

            x = origX;
            y = origY;

            offset.set(position[0], position[1]);

            idleAnim = json.idle_anim;
            confirmAnim = json.confirm_anim;

            if(removePreviousShit)
            {
                animation.remove("idle");
                animation.remove("confirm");
            }

            animation.addByPrefix("idle", idleAnim, 24, true);
            animation.addByPrefix("confirm", confirmAnim, 24, true);

            playAnim('idle');
        }
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        if(animation.getByName(AnimName) != null)
            animation.play(AnimName, Force, Reversed, Frame);
    }
}
