package ploverlearn.stenoplat;
import haxe.Timer;
import openfl.Lib;

/**
 * ...
 * @author larsiusprime
 */
class Metrics
{
	public var seconds(default, null):Int = 0;
	public var words(default, null):Int = 0;
	public var letters(default, null):Int = 0;
	public var misstrokes(default, null):Int = 0;
	public var streak(default, null):Int = 0;
	public var bestStreak(default, null):Int = 0;
	
	public var wpm(get, null):Int = 0;
	
	private var _timer:Timer;
	
	public function new() 
	{
		
	}
	
	public function logStreak(b:Bool):Void
	{
		if (b)
		{
			streak ++;
			if (streak > bestStreak)
			{
				bestStreak = streak;
			}
		}
		else
		{
			streak = 0;
		}
	}
	
	public function logMisstroke():Void
	{
		misstrokes++;
		trace("misstrokes = " + misstrokes);
	}
	
	public function logWord(word:String):Void
	{
		if (word.indexOf(" ") != -1)
		{
			var splitSpaces = word.split(" ");
			if (splitSpaces != null)
			{
				var num = splitSpaces.length;
				words += num;
				for (w in splitSpaces)
				{
					letters += w.length;
				}
			}
		}
		else
		{
			words++;
			letters += word.length;
		}
	}
	
	public function reset():Void
	{
		seconds = 0;
		words = 0;
		letters = 0;
		misstrokes = 0;
		streak = 0;
		bestStreak = 0;
		if (_timer != null)
		{
			_timer.stop();
		}
	}
	
	public function startTime():Void
	{
		if (_timer != null) _timer.stop();
		
		_timer = new Timer(1000);
		_timer.run = function() { seconds++; };
	}
	
	public function stopTime():Void
	{
		if(_timer != null) _timer.stop();
	}
	
	private function get_wpm():Int
	{
		return Std.int(words / (seconds / 60));
	}
}