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
	
	//Plover usually has ~5ms delay between text events belonging to the same stroke, this is 6x that for a generous margin of error, should still be more than tight enough
	private static inline var MAX_PLOVER_DELAY:Int = 30;
	
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
		
		initWordsField();
		initInputField();
		initHintField();
		initMetrics();
		
		inputField.addEventListener(TextEvent.TEXT_INPUT, txtListener);
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
		hintField = new NiceTextField("hint?", 20, 0xaaaaaa, 1.0, false);
		hintField.x = (stage.stageWidth / 2) - hintField.width / 2;
		hintField.y = 3 * stage.stageHeight / 4;
		hintField.addEventListener(MouseEvent.CLICK, onHintClick);
		this.addChild(hintField);
	}
	
	private function initMetrics()
	{
		metrics = new Metrics();
	}
	
	private function txtListener(e : TextEvent)
	{
		var time = Lib.getTimer();
		var elapsed = time - lastKeyTime;
		lastKeyTime = time;
		
		trace("text input = " + e.text);
		trace("elapsed = " + elapsed);
		
		lettersTyped++;
		
		if (_timer != null)
		{
			_timer.stop();
		}
		_timer = new Timer(MAX_PLOVER_DELAY);
		
		var str = (inputField.text + e.text).toLowerCase().replace(" ", "");
		if (str == wordsField.text.toLowerCase())
		{
			nextWord();
			e.preventDefault();
		}
		else
		{
			//set a timer, and if it runs out before the next text input event, count that as the end of the Plover stroke
			_timer.run = function () 
			{
				onInputText(e);
			}
		}
	}
	
	private function onInputText(e: TextEvent):Void
	{
		ploverStrokes++;
		var inStr = inputField.text.toLowerCase().replace(" ", "");
		var targStr = wordsField.text.toLowerCase();
		if(targStr.indexOf(inStr) != 0)
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
		metrics.startTime();
		exercise.reset();
		nextWord();
		stage.focus = inputField;
		inputField.text = "";
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

