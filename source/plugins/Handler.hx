package plugins;

import hscript.Interp;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class Handler {
    // finish this shit later
    var interp:Interp;
    public function Create(plugin:String, RunUnsafeCode:Bool, createFunc:String, addHaxeFlixelLIB:Bool) {
        var the:Array<String> = plugin.split(".");
        var script = Util.getText("plugins/" + the[0] + "/" + the[1]); 
        var parser = new hscript.Parser(); 
        var program = parser.parseString(script); 
        interp = new hscript.Interp(); 
        interp.variables.set("FlxSprite",FlxSprite); 
        interp.variables.set("FlxText",FlxText); 
        interp.variables.set("FlxG",FlxG);
        interp.variables.set(createFunc,function (append:Array<Dynamic>) {
            
        }); 
        interp.execute(program);
    }
}
