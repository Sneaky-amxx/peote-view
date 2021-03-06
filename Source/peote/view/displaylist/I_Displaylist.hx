package peote.view.displaylist;

/**
 * @author Sylvio Sell
 */

import peote.view.element.I_ElementBuffer;
import peote.view.element.ElementParam;
import peote.view.Buffer;

@:keep
interface I_Displaylist 
{
	public var type:Int;
	public var maxElements:Int;
	public var bufferSegmentSize:Int;
	public var bufferSegments:Int;
	
	public var prev:I_Displaylist; // pref displaylist (in order)
	public var next:I_Displaylist; // next displaylist (in order)

	public var x:Int; // x Position
	public var y:Int; // y Position
	public var w:Int; // width
	public var h:Int; // height
	
	public var z:Int; // z order

	public var xOffset:Float; // x Offset for all Elements
	public var yOffset:Float; // y Offset for all Elements

	public var zoom:Float; // zoom level

	public var blend:Int; // blend mode

	public var r:Float; // red bg
	public var g:Float; // green bg
	public var b:Float; // blue bg
	public var a:Float; // blue bg

	public var renderBackground:Bool;
	public var enable:Bool;

	public var renderToTexture:Bool;
	public var texture:Int;

	
	public var buffer:Buffer;
	public var elemBuff:I_ElementBuffer;
	

	public function set(param:DisplaylistParam):Void;
	public function delete():Void;
	
	public function setElement(param:ElementParam):Void;
	public function getElement(element_nr:Int):ElementParam;
	public function hasElement(element_nr:Int):Bool;
	public function delElement(element_nr:Int):Void;
	public function delAllElement():Void;
}