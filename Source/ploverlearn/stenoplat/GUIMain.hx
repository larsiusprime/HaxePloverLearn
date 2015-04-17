package ploverlearn.stenoplat;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.events.Event;
import flash.events.TextEvent;
import flash.text.TextFormat;
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
	private var fileName : String;
	
	private var metrics : Metrics;
	
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
	
	private function onExerciseLoaded(exercise : Exercise){
		this.exercise = exercise;
		
		loadExercise();
	}
	
	
	
	private function loadExercise(e : Event = null){
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
	
	private function drawBackground(){
		graphics.beginFill(0x00000000);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();
	}
	
	private function initWordsField(){
		
		
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
	
	private function initInputField(){
		
		
		
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
	
	
	private function initHintField(){
		hintField = new NiceTextField("hint?", 20, 0xaaaaaa, 1.0, false);
		hintField.x = (stage.stageWidth / 2) - hintField.width / 2;
		hintField.y = 3 * stage.stageHeight / 4;
		hintField.addEventListener(MouseEvent.CLICK, onHintClick);
		this.addChild(hintField);
	}
	
	private function initMetrics()
	{
		metrics = new Metrics();
		metrics.startTime();
	}
	
	private function txtListener(e : TextEvent){
		lettersTyped++;
		if ((inputField.text + e.text).toLowerCase().replace(" ", "") == wordsField.text.toLowerCase())
		{
			nextWord();
			
			e.preventDefault();
		}
		else if (lettersTyped > 10) {
			hintField.visible = true;
		}
	}
	
	private function nextWord(){
		
		metrics.logWord(wordsField.text);
		
		if (exercise.hasNextWord()) {
			exercise.nextWord();
			wordsField.text = exercise.word();
			
			hintField.text = "hint?";
		}
		else {
			finish();
		}
		
		inputField.text = "";
		hintField.visible = false;
		lettersTyped = 0;
	}
	
	private function finish()
	{
		metrics.stopTime();
		endSplash.show(metrics);
	}
	
	private function onHideSplash(){
		
		reset();
	}
	
	private function reset(){
		exercise.reset();
		nextWord();
		stage.focus = inputField;
		inputField.text = "";
	}
	
	private function onClick(e : Event){
		stage.focus = inputField;
	}
	
	private function onHintClick(e : Event){
		hintField.text = exercise.hint();
	}
}

