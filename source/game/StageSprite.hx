package game;

import flixel.FlxSprite;
import flixel.FlxG;

class StageSprite extends FlxSprite
{
    var swagBop:Bool = false;
    public var bopLeftRight:Bool = false;
    public var firstAnim:String = "idle";
    public var isAnimated:Bool = false;

    public function new(x:Float, y:Float, ?bopLeftRight:Bool = false)
    {
        super(x, y);

        this.bopLeftRight = bopLeftRight;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(isAnimated)
        {
            if(!bopLeftRight)
            {
                if(animation.curAnim.name != firstAnim && animation.curAnim.finished)
                    animation.play(firstAnim);
            }
        }
    }

    public function beatHit()
    {
        if(isAnimated)
        {
            if(bopLeftRight)
            {
                if(!swagBop)
                    animation.play('danceLeft');
                else
                    animation.play('danceRight');
            }
        }
    }
}