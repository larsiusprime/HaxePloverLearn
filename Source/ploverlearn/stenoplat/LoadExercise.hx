package ploverlearn.stenoplat;

import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.events.Event;
import flash.display.Sprite;
import flash.display.LoaderInfo;
import flash.display.Loader;
import flash.errors.IOError;
import openfl.Assets;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import ploverlearn.stenoplat.Exercise;

import openfl.errors.Error;
import flash.text.TextField;

using StringTools;

/**
 * ...
 * @author EN
 * 
 * Load an exercise from a file in the format of Learn Plover! exercise solutions 
 * (cut and pasted from Learn Plover! site into each lesson.txt)
 * into an Exercise object.
 * 
 */

class LoadExercise extends Sprite
{
	private var onExerciseLoaded : Exercise->Void;
	private var fileName : String;
	
	public function new(fileName:String, onExerciseLoaded:Exercise->Void)
	{
		super();
		
		this.onExerciseLoaded = onExerciseLoaded;
		this.fileName = fileName;
	}
	
	public function load()
	{
		var loader : URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, myCompleteHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		trace("URLLoader: " + loader);
		try
		{
			loader.load(new URLRequest(fileName));
		}
		catch (e : Error)
		{
			onError(null);
		}
	}
	
	private function onError(e : Event) : Void
	{
		if (Assets.exists("assets/" + fileName))
		{
			var asset = Assets.getText("assets/" + fileName);
			if (asset != null)
			{
				onExerciseLoaded(parseFile(asset));
			}
		}
		else
		{
			trace(e);
		}
	}
	
	private function myCompleteHandler(event : Event) : Void
	{
		var loader : URLLoader = cast (event.target);
		onExerciseLoaded(parseFile(loader.data));
	}
	
	private function parseFile(fileTxt : String) : Exercise
	{
		var lines : Array<String> = fileTxt.split("\n");
		var lessonTitle = noreturn(lines[0]);
		var exerciseName = noreturn(lines[1]);
		var words : Array<WordAndHint> = new Array<WordAndHint>();
		for (i in 2...lines.length)
		{
			var line : String = noreturn(lines[i]);
			var wordAndHint : Array<String> = line.split("\': ");
			var word : String = wordAndHint[0];
			word = word.substring(1, word.length);
			var hint = wordAndHint[1];
			words.push({word:word,hint:hint});
		}
		
		return new Exercise(lessonTitle, exerciseName, words);
	}
	
	private function noreturn(s : String) : String
	{
		return s.replace("\r","");
	}
}

typedef WordAndHint = {
	var word : String;
	var hint : String;
}

