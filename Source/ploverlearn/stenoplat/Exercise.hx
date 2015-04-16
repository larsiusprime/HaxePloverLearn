package ploverlearn.stenoplat;

import ploverlearn.stenoplat.LoadExercise.WordAndHint;

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
	
	public function new(lessonTitle:String, exerciseName:String, words:Array<WordAndHint>)
	{
		this.lessonTitle = lessonTitle;
		this.exerciseName = exerciseName;
		this.words = words;
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
	
	public function hint() : String
	{
		return words[wordIndex].hint;
	}
	
	
	public function randomize()
	{
		words.sort(_randomize);
	}
	
	private function _randomize(a : WordAndHint, b : WordAndHint) : Int
	{
		return ((Math.random() > .5)) ? 1 : -1;
	}
}

