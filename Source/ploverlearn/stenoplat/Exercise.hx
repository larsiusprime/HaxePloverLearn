package ploverlearn.stenoplat;

import ploverlearn.stenoplat.LoadExercise.WordAndHint;
import ploverlearn.stenoplat.LoadExercise.Setting;

/**
 * ...
 * @author EN
 */

class Exercise
{
	public var lessonTitle : String;
	public var exerciseName : String;
	public var words : Array<WordAndHint>;
	public var wordIndex : Int = -1;
	public var random : Bool = false;
	
	public var caseSensitive(default, null):Bool = false;
	public var requireSpaces(default, null):Bool = false;
	public var noticeSpaces(default, null):Bool = false;
	public var ignoredChars(default, null):Array<String> = null;
	
	public function new(lessonTitle:String, exerciseName:String, words:Array<WordAndHint>, ?settings:Array<Setting>)
	{
		this.lessonTitle = lessonTitle;
		this.exerciseName = exerciseName;
		this.words = words;
		
		_setSettings(settings);
		
		if (random)
		{
			randomize();
		}
	}
	
	public function toString() : String
	{
		return "Exercise:\n lessonTitle=\'" + lessonTitle + "\'\n exerciseName=\'" + exerciseName + "\'\n words=" + words;
	}
	
	public function nextWord() : Void
	{
		wordIndex++;
	}
	
	public function hasNextWord() : Bool
	{
		return wordIndex < words.length - 1;
	}
	
	public function reset()
	{
		wordIndex = -1;
	}
	
	public function word() : String
	{
		return words[wordIndex].word;
	}
	
	public function peekWord(i:Int) : String
	{
		if (wordIndex + i < words.length && wordIndex + i >= 0)
		{
			return words[wordIndex+i].word;
		}
		return "";
	}
	
	public function hint() : String
	{
		return words[wordIndex].hint;
	}
	
	public function randomize()
	{
		words.sort(_randomize);
	}
	
	private function _setSettings(settings:Array<Setting>):Void
	{
		for (setting in settings)
		{
			switch(setting.name.toLowerCase())
			{
				case "case_sensitive": caseSensitive = boolify(setting.value);
				case "require_spaces": requireSpaces = boolify(setting.value);
				case "notice_spaces": noticeSpaces = boolify(setting.value);
				case "ignore_characters": ignoredChars = arrayify(setting.value);
			}
		}
	}
	
	private function arrayify(str:String):Array<String>
	{
		if (str == "" || str == null)
		{
			ignoredChars = [];
		}
		else
		{
			var firstChar = str.charAt(0);
			var lastChar = str.charAt(str.length-1);
			if (firstChar == "'" && lastChar == "'" || firstChar == '"' && lastChar == '"' )
			{
				str = str.substr(1, str.length - 2);
			}
			ignoredChars = str.split(",");
		}
		return ignoredChars;
	}
	
	private function boolify(str:String):Bool
	{
		str = str.toLowerCase();
		if (str == "1" || str == "true")
		{
			return true;
		}
		return false;
	}
	
	private function _randomize(a : WordAndHint, b : WordAndHint) : Int
	{
		return ((Math.random() > .5)) ? 1 : -1;
	}
}

