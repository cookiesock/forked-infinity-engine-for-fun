package game;

import mods.Mods;
import Util;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;

class BGSprite
{
    public function new(xLmao:Float, yLmao:Float, animated:Bool, spritePath:String)
    {
        if animated == true
        {
            pissPNG = Util.getImage(spritePath);
            pissXML = Util.getText(spritePath + '.xml');

            piss = new FlxSprite(xLmao, yLmao);

            piss.tex = FlxAtlasFrames.fromSparrow(pissPNG, pissXML);
        }
        if !animated
        {
            pissPNG = Util.getImage(spritePath);
            
            piss = new FlxSprite(xLmao, yLmao).loadGraphic(pissPNG);
        }
    }
}