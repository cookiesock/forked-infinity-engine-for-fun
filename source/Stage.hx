/*package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;*/

/*typedef StageFile = {
    var character_Positions:Array<Array<Int>>;
    var camera_Zoom:Float;
    var objects:Array<ObjectData>;
}

typedef ObjectData = {
    var position:Array<Int>;
    var scroll_Factor:Array<Float>;
    var scale:Int;
    var antialiased:Bool;
    var file_Name:String;
    var is_Animated:Bool;
}*/

/*class Stage extends FlxTypedGroup<FlxSprite> {
    public function new(name) {
        var json:Dynamic = Util.getJsonContents('assets/stages/$name/data.json');
        var jsonObjs:Array<Dynamic> = json.objects;
        for (i in jsonObjs) {
            var object:FlxSprite = new FlxSprite(i.position[0], i.position[1]);
            if (i.is_Animated) {
                object.frames = Util.getSparrow('assets/stages/' + name + '/' + i.file_Name, false);
            } else {
                object.loadGraphic('assets/stages/' + name + '/' + i.file_Name + '.png');
            }
            object.scale.set(i.scale, i.scale);
            object.updateHitbox();
            object.scrollFactor.set(i.scroll_Factor[0], i.scroll_Factor[1]);
            object.antialiasing = i.antialiased;
            add(object);
        }
        super();
    }
}*/