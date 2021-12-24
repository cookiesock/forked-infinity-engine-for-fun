package ui;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class AlphabetText extends FlxSpriteGroup
{
    // Public Variables //
    public var text:String = "coolswag";

    public var targetY:Int = 0;
    public var isMenuItem:Bool = false;

    public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

    // Private Variables //
    private var bold:Bool = true;

    private var splitText:Array<String> = [];
    private var splitLines:Array<String> = [];

    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?bold_Param:Bool = true, ?text_Param:String = "coolswag", ?size:Float = 70/*, ?typed:Bool = false temporarily disabled until i wanna make it work lol*/)
    {
        super(x,y);

        text = (bold_Param ? text_Param.toLowerCase() : text_Param);
        bold = bold_Param;
        splitText = text.split("");

        var startingX:Float = 0;
        var curLine:Int = 0;

        for(i in 0...splitText.length)
        {
            var character:String = splitText[i];

            if(character != " " && character != "")
            {
                var alphabetChar:AlphabetCharacter = new AlphabetCharacter(character, i, bold, curLine, startingX, size);
                add(alphabetChar);

                startingX += alphabetChar.width + 4*(size/70);
            } else if (character == "\n") {
                curLine ++;
                startingX = 0;

                var alphabetChar:AlphabetCharacter = new AlphabetCharacter(character, i, bold, curLine, startingX, size);
                add(alphabetChar);

                startingX += alphabetChar.width + 4*(size/70);
            }
            else
                startingX += (size*(size/70))/2;
        }
    }

	override function update(elapsed:Float)
	{
		if(isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = Util.boundTo(elapsed * 9.6, 0, 1);
			
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);

			if(forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
			}
		}

		super.update(elapsed);
	}
}

class AlphabetCharacter extends FlxSprite
{
    // Public Variables //
    public var bold:Bool = true;

    // Static Variables //
    public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

    public static var numbers:String = "0123456789";

    public function new(character:String = "a", ?id:Int, ?bold_Param:Bool = true, line:Int = 0, ?startX:Float = 0.0, ?size:Float = 70)
    {
        super();

        x = startX;
        y = (line*size)+8*(size/70);

        bold = bold_Param;

        if(id != null)
            ID = id;

        frames = Util.getSparrow("Alphabet");

        if(bold)
        {
            if(numbers.split("").contains(character))
                animation.addByPrefix("default", "bold" + character.toUpperCase() + "0", 24);
            else if(alphabet.split("").contains(character))
                animation.addByPrefix("default", character.toUpperCase() + " bold0", 24);
            else
                animation.addByPrefix("default", "bold " + character.toUpperCase() + "0", 24);
        }
        else
        {
            var lowercase = character.toLowerCase() == character;

            if(alphabet.split("").contains(character.toLowerCase()))
                animation.addByPrefix("default", character + (lowercase ? " lowercase0" : " capital0"), 24);
            else
                animation.addByPrefix("default", character + "0", 24);
        }

        animation.play("default", true);

        scale.set(size/70, size/70);
        updateHitbox();
    }
}
