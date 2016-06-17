/*
 *        o-o    o-o  o-o-o  o-o     
 *       o   o  o        o      o    
 *      o-o-o  o-o   o    o    o-o   
 *     o      o     (_)    o      o  
 *    o      o-o    / \     o    o-o 
 * 
 * PEOTE VIEW - haxe 2D OpenGL Render Library
 * Copyright (c) 2014 Sylvio Sell, http://maitag.de
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package samples;

import haxe.Timer;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.ui.Touch;
import lime.ui.Window;
import lime.graphics.Renderer;

import de.peote.view.PeoteView;
import de.peote.view.displaylist.DisplaylistType;

class Sample extends Application {
	
    public var width: Int;
    public var height: Int;
    public var mouse_x: Int = 0;
    public var mouse_y: Int = 0;
    public var xOffset: Int = 0;
    public var yOffset: Int = 0;
    public var zoom: Int = 1;
	
	private var peoteView:PeoteView;
	private var startTime:Float;
	
	public function new () { super (); }
	//public override function create (config:Config):Void [ super.create (config) };

	public override function onWindowCreate (window:Window):Void
	{
		switch (window.renderer.context) {
			case OPENGL (gl):
				width = window.width;
				height = window.height;
				//run(); // start Example Code (override by child example classes)				
			default:
				trace("only opengl supported");
		}
	}
	
	public function run() //start Example
	{
		startTime = Timer.stamp();
		var t:Float = Timer.stamp() - startTime;
		
		peoteView = new PeoteView({
			maxDisplaylists:    10,
			maxPrograms:       100,
			maxTextures:         8,
			maxImages:        1000
		});
		
		// -----------------------------------------------------
		// ---------------- PROGRAM SHADER ---------------------
		// -----------------------------------------------------
		peoteView.setProgram({
			program: 0,
			fshader: "assets/lyapunov_01.frag"
		});
		
		// -----------------------------------------------------
		// ------------------- IMAGES --------------------------
		// -----------------------------------------------------
		peoteView.setImage({
			image: 0,
			filename: "assets/peote_font_white.png",
		});
		peoteView.setImage({
			image: 1,
			filename: "assets/peote_tiles.png",
		});
		
		
		// -----------------------------------------------------
		// ---------------- DISPLAYLISTS -----------------------
		// -----------------------------------------------------
		peoteView.setDisplaylist({
			displaylist:0,
			type:DisplaylistType.RGBA,
			
			maxElements:100,
			maxPrograms:10,
			bufferSegments:10,
			
			x:150, y:50,
			w:1000, h:1000,
			z:0,
			
			enable:true
		});
		
		peoteView.setDisplaylist({
			displaylist:1,
			type:DisplaylistType.ANIM,
			
			maxElements:1000,
			maxPrograms:10,
			bufferSegments:10,
			
			x:100, y:70,
			w:350, h:150,
			z:1,
			
			renderBackground:true,
			r:0.1, g:0.5, b:0.8, a:0.8,
			
			enable:true
		});
		
		// -----------------------------------------------------
		// ---------------- ELEMENTS ---------------------------
		// -----------------------------------------------------
		
		peoteView.setElementDefaults({ displaylist:0, z:1, image:1, tile:2 });
		
		peoteView.setElement( { element:0,
			x: -50000,
			y: -50000,
			w:100000, h:100000,
			tw: 10000000, th:10000000,
			program:0
		});
		
		peoteView.setElement( { element:1, image:0, tile:65,
			x: 211, y: 0,
			w:222, h:222,
			rgba: random(256) << 24 | random(256) << 16 | random(256) << 8 | random(256)
		});
		
		// ----new element of displaylist 1 with animation
		peoteView.setElement( { element:0, displaylist:1,
			x:0, y:0,
			end:{x:100, time: Timer.stamp() - startTime +10},
			w:100, h:100,
			tile:1
		});
	}
	/*
	public override function update (deltaTime:Int):Void {
		trace(deltaTime);		
	}
	*/
	
	// -- Math-Stuff
	private inline function random(n:Int):Int
	{
		return Math.floor(Math.random() * n);
	}
	
	// ------------------------------------------------------------
	// ------------------------------------------------------------
	
	// ----------- Render Loop ------------------------------------
	public override function render(renderer:Renderer):Void
	{
		//switch (renderer.context) { case OPENGL (gl): }
		peoteView.render(Timer.stamp() - startTime, width, height, mouse_x, mouse_y, zoom, xOffset, yOffset);
	}

	
	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	public override function onWindowResize (window:Window, width:Int, height:Int):Void
	{
		trace("onWindowResize:"+ window.width+','+ window.height);
		this.width = window.width;
		this.height = window.height;
	}
	
	public override function onMouseMove (window:Window, x:Float, y:Float):Void
	{
		//trace("onMouseMove: " + x + "," + y );
		mouse_x = Std.int(x);
		mouse_y = Std.int(y);
		setOffsets();
	}
	
	public override function onTouchMove (touch:Touch):Void
	{
		trace("onTouchMove: " + touch.x + "," + touch.y );
		mouse_x = Std.int(touch.x); //* window.width;
		mouse_y = Std.int(touch.y);
		setOffsets();
	}
	
	public override function onMouseDown (window:Window, x:Float, y:Float, button:Int):Void
	{	
		trace("onMouseDown: x=" + x + " y="+ y);
		if ( button == 0) zoom++;
		else if (button == 1 && zoom > 1) zoom--;
		setOffsets();
	}
	
	public override function onMouseUp (window:Window, x:Float, y:Float, button:Int):Void
	{	
		trace("onmouseup: "+button+" x=" + x + " y="+ y);
	}
	
	public override function onMouseWheel (window:Window, deltaX:Float, deltaY:Float):Void
	{	
		trace("onmousewheel: " + deltaX + ',' + deltaY );
		if ( deltaY>0 ) zoom++;
		else if (zoom > 1) zoom--;
		setOffsets();
	}

	public override function onRenderContextLost (renderer:Renderer):Void
	{		
		trace(" --------- ERROR :  LOST RENDERCONTEXT ----------- ");		
	}
	
	public override function onRenderContextRestored (renderer:Renderer, context:RenderContext):Void
	{
		trace(" --------- onRenderContextRestored ----------- ");		
	}
	
	public override function onPreloadProgress (loaded:Int, total:Int):Void
	{		
		trace(" --------- onPreloadProgress ----------- ");		
	}
	
	public override function onPreloadComplete ():Void
	{		
		trace(" --------- onPreload Complete ----------- ");
		run();
	}
	
	public override function onKeyDown (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F:
				#if html5
				var e:Dynamic = untyped __js__("document.getElementById('content').getElementsByTagName('canvas')[0]");
				var noFullscreen:Dynamic = untyped __js__("(!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement)");
				
				if ( noFullscreen)
				{	// enter fullscreen
					if (e.requestFullScreen) e.requestFullScreen();
					else if (e.msRequestFullScreen) e.msRequestFullScreen();
					else if (e.mozRequestFullScreen) e.mozRequestFullScreen();
					else if (e.webkitRequestFullScreen) e.webkitRequestFullScreen();
				}
				else
				{	// leave fullscreen
					var d:Dynamic = untyped __js__("document");
					if (d.exitFullscreen) d.exitFullscreen();
					else if (d.msExitFullscreen) d.msExitFullscreen();
					else if (d.mozCancelFullScreen) d.mozCancelFullScreen();
					else if (d.webkitExitFullscreen) d.webkitExitFullscreen();					
				}
				#else
				window.fullscreen = !window.fullscreen;
				#end				
			default:
		}
	}
	
	// end Event Handler ------------------------------
	// ------------------------------------------------------------
	
	public function setOffsets():Void {
		xOffset = Std.int( - width*(zoom-1)/zoom * mouse_x/width);
		yOffset = Std.int( - height*(zoom-1)/zoom * mouse_y/height);
	}

	
}
