package ploverlearn.stenoplat;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.events.Event;
import flash.events.TextEvent;
import flash.text.TextFormat;
import haxe.Timer;
import openfl.Lib;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldType;

using StringTools;

/**
 * ...
 * @author EN
 * 
 * The main drill page.
 * 
 */

class GUIMain extends Sprite
{
	private var WIDTH : Int = 500;
	private var HEIGHT : Int = 200;
	private var inputField : TextField;
	private var wordsField : TextField;
	private var hintField : TextField;
	private var settingsField : TextField;
	private var word : String;
	private var exercise : Exercise;
	private var endSplash : SplashScreen;
	private var startSplash : SplashScreen;
	private var lettersTyped : Int;
	private var ploverStrokes : Int;
	private var misstrokes : Int;
	private var fileName : String;
	
	private var metrics : Metrics;
	private var lastKeyTime:Float = 0;
	
	private var _timer:Timer;
	private var _deltimer:Timer;
	private var _delarray:Array<Int>;
	
	private var started:Bool = false;
	
	//Plover usually has ~5ms delay between text events belonging to the same stroke, this is 6x that for a generous margin of error, should still be more than tight enough
	private static inline var MAX_PLOVER_DELAY:Int = 30;
	private static inline var BACKSPACE_KEY:Int = 8;
	
	public function new(fileName)
	{
		super();
		this.fileName = fileName;
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(e : Event = null) : Void
	{
		var loader : LoadExercise = new LoadExercise(fileName, onExerciseLoaded);
		this.addChild(loader);
		loader.load();
	}
	
	private function onExerciseLoaded(exercise : Exercise)
	{
		this.exercise = exercise;
		
		loadExercise();
	}
	
	private function loadExercise(e : Event = null)
	{
		drawBackground();
		
		initSettingsField();
		initWordsField();
		initInputField();
		initHintField();
		initMetrics();
		
		inputField.addEventListener(TextEvent.TEXT_INPUT, txtListener);
		parent.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
		parent.addEventListener(MouseEvent.CLICK, onClick);
		
		endSplash = new SplashScreen(exercise.lessonTitle + "\nFinished!", "Click to re-start.", onHideSplash);
		addChild(endSplash);
		
		startSplash = new SplashScreen(exercise.lessonTitle + ":\n" + exercise.exerciseName, "Click to start", onHideSplash);
		addChild(startSplash);
		startSplash.show();
		nextWord();
	}
	
	private function drawBackground()
	{
		graphics.beginFill(0x00000000);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();
	}
	
	private function initWordsField()
	{
		var wordsFieldFormat : TextFormat = new TextFormat();
		wordsFieldFormat.size = 40;
		wordsFieldFormat.bold = true;
		wordsFieldFormat.align = TextFormatAlign.CENTER;
		
		
		wordsField = new TextField();
		wordsField.textColor = 0xffffff;
		wordsField.type = TextFieldType.DYNAMIC;
		wordsField.text = "words go here...";
		wordsField.setTextFormat(wordsFieldFormat);
		wordsField.defaultTextFormat = wordsFieldFormat;
		wordsField.width = wordsField.textWidth + 10;
		wordsField.height = wordsField.textHeight + 10;
		wordsField.x = (stage.stageWidth / 2) - wordsField.width / 2;
		wordsField.y = (stage.stageHeight / 2) - wordsField.height;
		wordsField.selectable = false;
		
		this.addChild(wordsField);
	}
	
	private function initSettingsField()
	{
		settingsField = new NiceTextField("settings", 15, 0xaaaaaa, 1.0, false, stage.stageWidth);
		settingsField.height = 200;
		settingsField.x = (stage.stageWidth / 2) - settingsField.width / 2;
		settingsField.y = 1 * stage.stageHeight / 8;
		
		var strs = [];
		
		if (exercise.caseSensitive)
		{
			strs.push("CASE SENSITIVE");
		}
		
		if (exercise.requireSpaces)
		{
			strs.push("SPACES REQUIRED");
		}
		
		if (exercise.ignoredChars != null)
		{
			strs.push("IGNORING: (" + exercise.ignoredChars.join(",")+")");
		}
		
		if (strs.length != 0)
		{
			settingsField.text = strs.join(", ");
		}
		else
		{
			settingsField.text = "";
		}
		
		this.addChild(settingsField);
	}
	
	private function initInputField()
	{
		var inputFieldFormat : TextFormat = new TextFormat();
		inputFieldFormat.size = 20;
		inputFieldFormat.bold = true;
		inputFieldFormat.align = TextFormatAlign.CENTER;
		
		inputField = new TextField();
		inputField.setTextFormat(inputFieldFormat);
		inputField.defaultTextFormat = inputFieldFormat;
		inputField.textColor = 0xaaaaaa;
		inputField.type = TextFieldType.INPUT;
		inputField.border = true;
		inputField.text = "even more words go here";
		inputField.width = inputField.textWidth + 5;
		inputField.height = inputField.textHeight + 3;
		inputField.x = (stage.stageWidth / 2) - inputField.width / 2;
		inputField.y = (stage.stageHeight / 2) + inputField.height;
		
		this.addChild(inputField);
		stage.focus = inputField;
	}
	
	
	private function initHintField()
	{
		hintField = new NiceTextField("hint?", 20, 0xaaaaaa, 1.0, false, stage.stageWidth);
		hintField.x = (stage.stageWidth / 2) - hintField.width / 2;
		hintField.y = 3 * stage.stageHeight / 4;
		hintField.addEventListener(MouseEvent.CLICK, onHintClick);
		this.addChild(hintField);
	}
	
	private function initMetrics()
	{
		metrics = new Metrics();
	}
	
	private function wordEndsIn(word:String,arr:Array<String>):Bool
	{
		var end = word.length - 1;
		for (str in arr)
		{
			if (word.indexOf(str) == end)
			{
				return true;
			}
		}
		return false;
	}
	
	private function keyListener(e : KeyboardEvent)
	{
		if (_delarray == null) _delarray = [];
		_delarray.push(e.keyCode);
		
		if (_deltimer != null)
		{
			_deltimer.stop();
		}
		_deltimer = new Timer(MAX_PLOVER_DELAY);
		_deltimer.run = function ()
		{
			onCheckDelete();
		}
	}
	
	private function onCheckDelete()
	{
		var oneDelete:Bool = false;
		var oneNormal:Bool = false;
		
		var allDelete:Bool = false;
		var isTransform:Bool = false;
		
		for (key in _delarray)
		{
			if (key != BACKSPACE_KEY) oneNormal = true;
			else oneDelete = true;
		}
		
		allDelete = oneDelete && !oneNormal;
		isTransform = oneDelete && oneNormal;
		
		if (allDelete)
		{
			onDelete();
		}
		if (isTransform)
		{
			onTransform();
		}
		
		_deltimer.stop();
		_delarray = [];
	}
	
	private function onDelete():Void
	{
		//if I want to do something here
	}
	
	private function onTransform():Void
	{
		metrics.forgive();
	}
	
	private function txtListener(e : TextEvent)
	{
		if (!started)
		{
			started = true;
			metrics.startTime();
		}
		
		var time = Lib.getTimer();
		var elapsed = time - lastKeyTime;
		lastKeyTime = time;
		
		lettersTyped++;
		
		if (_timer != null){ _timer.stop(); }
		_timer = new Timer(MAX_PLOVER_DELAY);
		
		//set a timer, and if it runs out before the next text input event, count that as the end of the Plover stroke
		_timer.run = function () 
		{
			onInputText(e);
		}
	}
	
	private function cleanField(field:TextField):Void
	{
		if (exercise.ignoredChars != null)
		{
			for (char in exercise.ignoredChars)
			{
				while (field.text.indexOf(char) == 0)
				{
					field.text = field.text.replace(char, "");
				}
			}
		}
	}
	
	private function cleanInput(inStr:String,targStr:String):{input:String,target:String}
	{
		if (!exercise.caseSensitive)
		{
			inStr = inStr.toLowerCase();
			targStr = targStr.toLowerCase();
		}
		
		//Plover sometimes inserts spaces between words
		//If there's a space at the BEGINNING of user input, it is always deleted
		while (inStr.indexOf(" ") == 0)
		{
			inStr = inStr.substr(1, inStr.length - 1);
		}
		
		if (!exercise.requireSpaces || wordEndsIn(targStr, [".", "?", "!", ";", ":"]))
		{
			inStr = inStr.replace(" ", "");
		}
		else
		{
			targStr = targStr + " ";
		}
		
		if (exercise.ignoredChars != null)
		{
			for (char in exercise.ignoredChars)
			{
				while (inStr.indexOf(char) != -1)
				{
					inStr = inStr.replace(char, "");
				}
				while (targStr.indexOf(char) != -1)
				{
					targStr = targStr.replace(char, "");
				}
			}
		}
		
		return { input:inStr, target:targStr };
	}
	
	private function onInputText(e: TextEvent):Void
	{
		ploverStrokes++;
		
		var clean = cleanInput(inputField.text, wordsField.text);
		var inStr = clean.input;
		var targStr = clean.target;
		
		cleanField(inputField);
		
		if (inStr == targStr)
		{
			nextWord();
			e.preventDefault();
		}
		else if(targStr.indexOf(inStr) != 0)
		{
			//if the text doesn't match, count that as a misstroke
			//note this doesn't look for a perfect match, just that what you've typed so far matches the beginning of the complete word
			//this way it's compatible with (most) multi-stroke words
			misstrokes++;
			metrics.logMisstroke();
			metrics.logStreak(false);
			
			//TODO: watch out for edge cases where Plover goes back and "corrects" previous strokes in multi-stroke words, these would be false positives
			//I think a heuristic that watches to see if you are able to complete the word in say, 4 strokes or less, without ever using the delete stroke,
			//should be able to infer that "all's well that ends well", and not count any of that as a misstroke.
			if (misstrokes > 2)
			{
				hintField.visible = true;
			}
		}
		_timer.stop();
	}
	
	private function nextWord()
	{
		metrics.logWord(wordsField.text);
		metrics.logStreak(true);
		
		if (exercise.hasNextWord())
		{
			exercise.nextWord();
			wordsField.text = exercise.word();
			
			hintField.text = "hint?";
		}
		else 
		{
			finish();
		}
		
		inputField.text = "";
		hintField.visible = false;
		lettersTyped = 0;
		ploverStrokes = 0;
		misstrokes = 0;
	}
	
	private function finish()
	{
		metrics.stopTime();
		endSplash.show(metrics);
	}
	
	private function onHideSplash()
	{
		reset();
	}
	
	private function reset()
	{
		metrics.reset();
		exercise.reset();
		nextWord();
		stage.focus = inputField;
		inputField.text = "";
		started = false;
	}
	
	private function onClick(e : Event)
	{
		stage.focus = inputField;
	}
	
	private function onHintClick(e : Event)
	{
		hintField.text = exercise.hint();
	}
}

