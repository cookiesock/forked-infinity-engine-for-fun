package ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class AlphabetText extends FlxSpriteGroup
{
    // Public Variables //
    public var text:String = "coolswag";

    // Private Variables //
    private var bold:Bool = true;

    private var splitText:Array<String> = [];

    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?bold_Param:Bool = true, ?text_Param:String = "coolswag"/*, ?typed:Bool = false temporarily disabled until i wanna make it work lol*/)
    {
        super(x,y);

        text = (bold_Param ? text_Param.toLowerCase() : text_Param);
        bold = bold_Param;

        splitText = text.split("");

        var startingX:Float = 0;

        for(i in 0...splitText.length)
        {
            var character:String = splitText[i];

            if(character != " " && character != "")
            {
                var alphabetChar:AlphabetCharacter = new AlphabetCharacter(character, i, bold, startingX);
                add(alphabetChar);

                startingX += alphabetChar.width + 4;
            }
            else
                startingX += 24;
        }
    }

    override function update(elapsed:Float) {
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

    public function new(character:String = "a", ?id:Int, ?bold_Param:Bool = true, ?startX:Float = 0.0)
    {
        super();

        x = startX;

        bold = bold_Param;

        if(id != null)
            ID = id;

        frames = Util.getSparrow("Alphabet");

        if(numbers.split("").contains(character))
            animation.addByPrefix("default", (bold ? "bold" : "") + character.toUpperCase() + "0", 24);
        else if(alphabet.split("").contains(character))
            animation.addByPrefix("default", character.toUpperCase() + (bold ? " bold0" : "0"), 24);
        else
            animation.addByPrefix("default", (bold ? "bold " : "") + character.toUpperCase() + "0", 24);

        animation.play("default", true);
    }
}