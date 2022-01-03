package game;

import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class Character extends FlxSprite {
    public var name = "bf";
    public var json:Dynamic;
    public var anims:Array<Dynamic> = [];
    public var offsetMap:Map<String, Array<Int>> = [];
    public var camOffsets:Array<Int> = [0,0];
    public var position:Array<Int> = [0,0];
    public var healthColor:Int = FlxColor.WHITE;
    public var bopLeftRight:Bool = false;
    public var bopDirection:Int = 0;
    public var isPlayer:Bool = false;
    public var holdTimer:Float = 0;
    public var healthIcon:String = "bf";

    public function new(x, y, name)
    {
        super(x, y);

        this.name = name;

        json = Util.getJsonContents('assets/characters/$name.json');

        frames = Util.getSparrow('assets/characters/images/$name/assets', false);

        // SPIRIT FUCKING CRASHES THE GAME IF THIS IS REMOVED, EITHER RE-EXPORT HIM AS AN XML
        // OR LEAVE HIM AS IS NOW, OTHERWISE THE GAME WILL CRASH
        // fuck you

        scale.set(json.scale, json.scale);
        updateHitbox();

        flipX = json.flip_x;
        antialiasing = !json.no_antialiasing;
        camOffsets = json.camera_position;
        healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
        position = json.position;

        anims = json.animations;

        if(json.healthicon != null)
            healthIcon = json.healthicon;
        else
            healthIcon = name;
        
        for (anim in anims) {
            if (anim.indices == null || anim.indices.length < 1) {
                animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
            } else {
                animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
            }

            offsetMap.set(anim.anim, anim.offsets);
        }
        
        bopLeftRight = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);

        //playAnim('idle');
        dance();
    }
    override public function update(elapsed) {
        super.update(elapsed);

        if(animation.curAnim.name.startsWith('sing'))
            holdTimer += elapsed;
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        animation.play(AnimName, Force, Reversed, Frame);
        offset.set(offsetMap[AnimName][0], offsetMap[AnimName][1]);
    }

    public function dance() {
        holdTimer = 0;
        
        if (bopLeftRight == true) {
            if (bopDirection == 0) {
                playAnim('danceLeft', true);
            } else {
                playAnim('danceRight', true);
            }

            bopDirection = (bopDirection + 1) % 2;
        }

        if (bopLeftRight == false) {
            playAnim('idle');
        }
    }
}
