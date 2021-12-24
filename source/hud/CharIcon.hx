package hud;

import flixel.FlxSprite;

using StringTools;

class CharIcon extends FlxSprite {
    public var tracker:FlxSprite;
    public var trackerLeft:Bool;
    public var char:String;
    
	public function new(char:String = 'bf')
        {
            super();
            changeIcon(char);
            scrollFactor.set();
        }
    
	override function update(elapsed:Float)
        {
            if (tracker != null) {
                if (!trackerLeft) {
                    setPosition(tracker.x + tracker.width + 10, tracker.y - 30);
                } else {
                    setPosition(tracker.x - 10 - width, tracker.y - 30);
                }
            }
            super.update(elapsed);
        }
        
        public function changeIcon(char:String) {
            if(this.char != char) {
                var imgPath = 'assets/characters/images/' + char + '/icons.png';
                this.char = char;
    
                loadGraphic(imgPath, true, 150, 150);
                animation.add('super_icon', [0, 1], 0, true);
                animation.play('super_icon');
                antialiasing = !char.endsWith('-pixel');
            }
        }

        public function changeTexture(path:String) {
            loadGraphic(path, true, 150, 150);
            animation.add('super_icon', [0, 1], 0, true);
            animation.play('super_icon');
            antialiasing = !path.endsWith('-pixel');
        }
}