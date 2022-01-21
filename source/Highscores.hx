package;

import flixel.FlxG;

using StringTools;

class Highscores
{
    public static var weekScores:Map<String, Array<Float>> = [];
    public static var songScores:Map<String, Array<Float>> = [];

    public static function init()
    {
        if(Options.getData('weekScores') != null)
            weekScores = Options.getData('weekScores');

        if(Options.getData('songScores') != null)
            songScores = Options.getData('songScores');
    }

    // songs
    public static function getSongScore(swagSong:String, swagDifficulty:String)
    {
        var score = songScores.get('$swagSong-$swagDifficulty');

        if(score == null)
        {
            score = [0, 0];
            songScores.set('$swagSong-$swagDifficulty', score);
            Options.saveData('songScores', songScores);
        }
        
        return score;
    }

    public static function saveSongScore(swagSong:String, swagDifficulty:String, value:Array<Float>)
    // tryna do a thing where's score and acc, like this: [93845, 99.98]
    {
        if(value[0] > getSongScore(swagSong, swagDifficulty)[0])
        {
            songScores.set('$swagSong-$swagDifficulty', value);
            Options.saveData('songScores', songScores);
        }
    }

    // weeks
    public static function getWeekScore(swagWeek:String, swagDifficulty:String)
    {
        var score = weekScores.get('$swagWeek-$swagDifficulty');

        if(score == null)
        {
            score = [0, 0];
            weekScores.set('$swagWeek-$swagDifficulty', score);
            Options.saveData('weekScores', weekScores);
        }

        return score;
    }

    public static function saveWeekScore(swagWeek:String, swagDifficulty:String, value:Array<Float>)
    {
        if(value[0] > getWeekScore(swagWeek, swagDifficulty)[0])
        {
            songScores.set('$swagWeek-$swagDifficulty', value);
            Options.saveData('weekScores', weekScores);
        }
    }
}