import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.events.KeyboardEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.LoaderInfo;
import flash.external.ExternalInterface;
import ploverlearn.stenoplat.Exercise;
import ploverlearn.stenoplat.GUIMain;

/**
 * ...
 * @author EN
 */

class Main extends Sprite
{
	private var fileName : String = "lesson.txt";
	
	public function new()
	{
		super();
		trace("Main: started");
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
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
		this.addChild(new GUIMain(fileName));
	}
	
	private function onExerciseLoaded(exercise : Exercise){
		trace("exercise loaded:");
		trace(exercise);
	}
}

