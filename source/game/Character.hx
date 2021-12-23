package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;

class Character extends FlxSprite {
    var name = "bf";
    var json:Dynamic;
    var anims:Array<Dynamic> = [];
    var offsetMap:Map<String, Array<Int>> = [];
    var camOffsets:Array<Int> = [0,0];
    var healthColor:Int = FlxColor.WHITE;
    var bopLeftRight:Bool = false;
    var bopDirection:Int = 0;
    public function new(x, y, name) {
        super(x, y);
        this.name = name;
        json = Util.getJsonContents('assets/characters/$name.json');
        frames = Util.getSparrow('assets/characters/images/$name/assets', false);

        scale.set(json.scale, json.scale);
        updateHitbox();
        flipX = json.flip_x;
        antialiasing = !json.no_antialiasing;
        camOffsets = json.camera_position;
        healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);

        anims = json.animations;
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
    }
    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        animation.play(AnimName, Force, Reversed, Frame);
        offset.set(offsetMap[AnimName][0], offsetMap[AnimName][1]);
    }
    public function dance() {
        if (bopLeftRight == true) {
            if (bopDirection == 0) {
                playAnim('danceLeft', true);
            } else {
                playAnim('danceRight', true);
            }
            bopDirection = (bopDirection + 1) % 2;
        }
        if (bopLeftRight == false) {
            playAnim('idle', true);
        }
    }
}