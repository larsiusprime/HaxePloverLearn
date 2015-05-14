package ploverlearn.stenoplat;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Bitmap;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormatAlign;

/**
 * ...
 * @author EN
 * 
 * SplashScreen: The intro screen
 */

class SplashScreen extends Sprite
{
	private var header : String;
	private var info : String;
	private var button : Sprite;
	private var BUFFER : Int = 50;
	private var infoField : TextField;
	private var metricsField : TextField;
	private var metricsFieldValues : TextField;
	private var metricsDark : Bitmap;
	private var headerField : TextField;
	private var onHide : Void->Void;
	
	private var screenHeight:Float = 0;
	private var screenWidth:Float = 0;
	
	public function new(header : String, info : String, onHide : Void->Void)
	{
		super();
		
		this.header = header;
		this.info = info;
		this.onHide = onHide;
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
		initBackground();
		
		headerField = new NiceTextField(header, 45, 0xffffff, 0.9);
		infoField = new NiceTextField(info, 25, 0xffffff, 0.8);
		metricsField = new NiceTextField("A\nB\nC\nD\nE\n", 20, 0xffffff, 1.0, false, this.width/4, TextFormatAlign.LEFT);
		metricsFieldValues = new NiceTextField("A\nB\nC\nD\nE\n", 20, 0xffffff, 1.0, false, this.width/4, TextFormatAlign.RIGHT);
		
		metricsField.height = (20 * 6);
		metricsFieldValues.height = metricsField.height;
		
		metricsDark = new Bitmap(new BitmapData(1, 1, true, 0x70000000));
		
		headerField.width = this.width;
		headerField.height = 2 * headerField.textHeight + 10;
		headerField.wordWrap = true;
		headerField.x = 0;
		headerField.y = height / 3;
		
		infoField.x = (width - infoField.width) / 2;
		infoField.y = 3 * height / 4;
		
		screenHeight = height;
		screenWidth = width;
		
		this.addChild(new Bitmap(Assets.getBitmapData("assets/plover.jpg")));
		
		this.addChild(infoField);
		this.addChild(headerField);
		this.addChild(metricsDark);
		this.addChild(metricsField);
		this.addChild(metricsFieldValues);
		
		metricsField.x = (width - metricsField.width);
		metricsField.y = (height - metricsField.textHeight);
		
		metricsFieldValues.x = metricsField.x;
		metricsFieldValues.y = metricsField.y;
		
		metricsDark.width = metricsField.textWidth;
		metricsDark.height = metricsField.textHeight;
		metricsDark.x = metricsField.x;
		metricsDark.y = metricsField.y;
		
		metricsField.text = metricsFieldValues.text = "";
		
		addEventListener(MouseEvent.CLICK, buttonClick);
		
		this.visible = false;
	}
	
	private function buttonClick(e : Event)
	{
		hide();
	}
	
	public function show(?m:Metrics)
	{
		this.visible = true;
		stage.focus = this.infoField;
		
		if (m != null)
		{
			metricsField.text =  "TIME:";
			metricsField.text += "\nWPM:";
			metricsField.text += "\nMisstrokes:";
			metricsField.text += "\nLast Streak:";
			metricsField.text += "\nBest Streak:";
			
			metricsFieldValues.text =  m.seconds + " sec.";
			metricsFieldValues.text += "\n"+m.wpm;
			metricsFieldValues.text += "\n"+m.misstrokes;
			metricsFieldValues.text += "\n"+m.streak;
			metricsFieldValues.text += "\n"+m.bestStreak;
			
			metricsField.y = screenHeight - metricsField.textHeight - 5;
			metricsFieldValues.y = metricsField.y;
			
			metricsDark.width = metricsField.width;
			metricsDark.height = metricsField.textHeight + 10;
			metricsDark.x = screenWidth - metricsDark.width;
			metricsDark.y = metricsField.y;
			metricsDark.visible = true;
			metricsField.visible = true;
		}
		else
		{
			metricsField.visible = false;
			metricsDark.visible = false;
		}
	}
	
	public function hide()
	{
		this.visible = false;
		onHide();
	}
	
	private function initBackground()
	{
		graphics.beginFill(0xbbbbbb);
		graphics.drawRoundRect(0, 0, stage.stageWidth - BUFFER, stage.stageHeight - BUFFER, 20);
		graphics.endFill();
		
		this.x = BUFFER / 2;
		this.y = BUFFER / 2;
	}
}

