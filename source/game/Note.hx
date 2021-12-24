package game;

import flixel.FlxSprite;

using StringTools;

// yes believe it or not this is actually written by me swordcube hrfjzksjLk;lk - swordcube
// i'm gonna start looking at the haxeflixel doc shit instead of yeeting fnf code now
// uaydysusfydsh

class Note extends FlxSprite {
	var resetAnim:Float = 0;
	var noteskin:String = 'default';
	var isPixel:Bool = false;
	var noteID:Int = 0;

	public function new(x, y, noteID:Int = 0, ?noteskin:String = 'default')
	{
		super(x, y);

		this.noteskin = noteskin;
		this.noteID = noteID;
		
		loadNoteShit(this.noteskin);
	}
	
	public function loadNoteShit(noteskin:String = 'default')
	{
		var json:Dynamic = Util.getJsonContents('assets/images/noteskins/' + noteskin + '/config.json');
		isPixel = json.isPixel; // this uses a json for config shit because gaming
		
		if(!isPixel) { // if the note skin is NOT pixel
			frames = Util.getSparrow('noteskins/' + noteskin + '/notes');
			
			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));
			
			switch(Math.abs(noteID % 4))
			{
				case 0:
					animation.addByPrefix('strum', 'left0', 24, false);
					animation.addByPrefix('tap', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);				
				case 1:
					animation.addByPrefix('strum', 'down0', 24, false);
					animation.addByPrefix('tap', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('strum', 'up0', 24, false);
					animation.addByPrefix('tap', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);					
				case 3:
					animation.addByPrefix('strum', 'right0', 24, false);
					animation.addByPrefix('tap', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		} else { // if the note skin is INDEED pixel
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'));
			width = width / 4;
			height = height / 5;
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'), true, Math.floor(width), Math.floor(height));
			
			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.pixelAssetZoom));
			
			switch(Math.abs(noteID % 4))
			{
				case 0:
					animation.add('strum', [0]);
					animation.add('tap', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('strum', [1]);
					animation.add('tap', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('strum', [2]);
					animation.add('tap', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('strum', [3]);
					animation.add('tap', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		
		updateHitbox();
		playAnim('strum', true);
	}
	
	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		
		centerOffsets();

		if(animation.curAnim.name == 'confirm' && !isPixel) {
			centerOrigin();
		}
	}
	
	override public function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('strum');
				resetAnim = 0;
			}
		}

		if(animation.curAnim.name == 'confirm' && !isPixel) {
			centerOrigin();
		}

		super.update(elapsed);
	}
}
