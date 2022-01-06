package mods;

import openfl.events.Event;
import openfl.media.Sound;
import flixel.system.FlxSound;

class ModSoundUtil extends FlxSound
{
    /**
	 * One of the main setup functions for sounds, this function loads a sound from a ByteArray.
	 *
	 * @param	path 			string path to sound lmfao.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.
	 * 							Default value is false, but `FlxG.sound.play()` and `FlxG.sound.stream()` will set it to true by default.
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadCoolModdedSound(path:String, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
    {
        cleanup(true);

		_sound = Sound.fromFile('./' + path);
        _sound.addEventListener(Event.ID3, gotID3);

        return init(Looped, AutoDestroy, OnComplete);
    }
}