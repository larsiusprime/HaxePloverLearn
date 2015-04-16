package ploverlearn.stenoplat;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
 * ...
 * @author EN
 * *
 * NiceTextField: A text field set up centered, bold, and unselectable, with the given text, size, and color. 
 */

class NiceTextField extends TextField
{
	
	public function new(text:String, size:Int, color:Int, alpha:Float, bold:Bool=true)
	{
		super();
		this.text = text;
		this.alpha = alpha;
		
		var inputFieldFormat : TextFormat = new TextFormat();
		inputFieldFormat.size = size;
		inputFieldFormat.bold = bold;
		inputFieldFormat.align = TextFormatAlign.CENTER;
		inputFieldFormat.color = color;
		
		setTextFormat(inputFieldFormat);
		defaultTextFormat = inputFieldFormat;
		
		width = textWidth + 100;
		height = textHeight + 3;
		selectable = false;
	}
}

