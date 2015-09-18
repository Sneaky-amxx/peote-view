/*
 *        o-o    o-o  o-o-o  o-o    
 *       o   o  o    _   o      o   
 *      o-o-o  o-o  (o)   o    o-o  
 *     o      o     / \    o      o 
 *    o      o-o   /  ))    o    o-o
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

package de.peote.view.element;

import de.peote.view.ProgramCache;
import de.peote.view.displaylist.DType;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.ArrayBufferView;
import haxe.ds.Vector;

//import lime.utils.Float32Array;
//import lime.utils.Int16Array;
class ElementSimpleBuffer implements I_ElementBuffer
{
	public static var VERTEX_COUNT:Int = 6;
	
	public var attr:Vector<Int> = null;
	public var glBuff:GLBuffer;
		
	var emptyBuffFull:BufferData;
	var buffFull:BufferData;
	
	var buffTex_0:BufferData;
	var buffTex_1:BufferData;
	var buffTex_2:BufferData;
	var buffTex_3:BufferData;
	
	var type:Int;
	
	var ZINDEX_OFFSET:Int;
	var RGBA_OFFSET:Int;
	var TEX_OFFSET:Int;
	var VERTEX_STRIDE:Int;

	public function new(t:Int, b:Buffer)
	{	
		type = t;
		
		var offset = 0;
		if (type & DType.ZINDEX != 0) { ZINDEX_OFFSET = offset+=4;  } 
		if (type & DType.RGBA != 0)   { RGBA_OFFSET   = offset+=4;  } 
		TEX_OFFSET    = offset+=4;
		VERTEX_STRIDE = offset+=4;
		
		
		var full = new BufferData(b.max_segments * b.segment_size * VERTEX_COUNT * VERTEX_STRIDE);

		// create new opengl buffer 
		glBuff = GL.createBuffer();
		GL.bindBuffer (GL.ARRAY_BUFFER, glBuff);
		GL.bufferData (GL.ARRAY_BUFFER, full.dataView , GL.STATIC_DRAW); // GL.DYNAMIC_DRAW GL.STREAM_DRAW
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		
		// ------------ BufferViews pre initialized -----------------
		buffFull      = new BufferData (VERTEX_COUNT * VERTEX_STRIDE);
		emptyBuffFull = new BufferData (VERTEX_COUNT * VERTEX_STRIDE);
		/*
		buffTex_0     = new BufferData (4);
		buffTex_1     = new BufferData (4);
		buffTex_2     = new BufferData (4);
		buffTex_3     = new BufferData (4);
		*/
	}
	
	public inline function delete():Void
	{
		GL.deleteBuffer(glBuff);
	}
	
	public inline function disableVertexAttributes():Void
	{
		GL.disableVertexAttribArray (attr.get(Program.aPOSITION));
		if (type & DType.ZINDEX != 0) GL.disableVertexAttribArray (attr.get(Program.aZINDEX));
		if (type & DType.RGBA != 0)   GL.disableVertexAttribArray (attr.get(Program.aRGBA));
		GL.disableVertexAttribArray (attr.get(Program.aTEXTCOORD));
	}
	public inline function setVertexAttributes():Void
	{		
		// vertexAttribPointers
		GL.enableVertexAttribArray (attr.get(Program.aPOSITION));
		if (type & DType.ZINDEX != 0) GL.enableVertexAttribArray (attr.get(Program.aZINDEX));
		if (type & DType.RGBA   != 0) GL.enableVertexAttribArray (attr.get(Program.aRGBA));
		GL.enableVertexAttribArray (attr.get(Program.aTEXTCOORD));
		
		GL.vertexAttribPointer (attr.get(Program.aPOSITION), 2, GL.SHORT, false, VERTEX_STRIDE, 0 );
		if (type & DType.ZINDEX != 0) GL.vertexAttribPointer (attr.get(Program.aZINDEX), 1, GL.FLOAT,         false, VERTEX_STRIDE, ZINDEX_OFFSET );
		if (type & DType.RGBA   != 0) GL.vertexAttribPointer (attr.get(Program.aRGBA  ), 4, GL.UNSIGNED_BYTE,  true, VERTEX_STRIDE, RGBA_OFFSET );
		
		// TODO: in ElementSimple berechnen! .. nur bei ANIM
		/*
		if (type & DType.ROTATION != 0) GL.vertexAttribPointer (attr.get(Program.aROTATION),  2, GL.SHORT, false, VERTEX_STRIDE, +12 );
		if (type & DType.PIVOT    != 0) GL.vertexAttribPointer (attr.get(Program.aPIVOT),     2, GL.SHORT, false, VERTEX_STRIDE, +16  );
		if (type & DType.PARAM_A  != 0) GL.vertexAttribPointer (attr.get(Program.aPARAM_A),   2, GL.SHORT, false, VERTEX_STRIDE, PARAM_OFFSET+4 );
		*/
		GL.vertexAttribPointer (attr.get(Program.aTEXTCOORD),2, GL.SHORT, false, VERTEX_STRIDE, TEX_OFFSET );// TODO: evtl. optimize mit medium_float
		// damit stride hinhaut einfach VERTEX_STRIDE erhoehen wenn noetig
	}

	/*
	public inline function bufferDataTex( b:BufferData, tx:Int, ty:Int ):Void
	{
		b.setByteOffset( 0 );
		b.write_2_Short( tx, ty );   // TEXT COORD 
		b.setByteOffset( 0 );
	}
	*/
	public inline function del(e:I_Element):Void
	{
		GL.bindBuffer (GL.ARRAY_BUFFER, glBuff);
		GL.bufferSubData(GL.ARRAY_BUFFER, e.buf_pos * VERTEX_STRIDE , emptyBuffFull.dataView);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		
	}

	public inline function set( e:I_Element, param:Param ):Void
	{
		var buf_pos:Int = e.buf_pos;
		
		var x:Int = param.x;
		var y:Int = param.y;
		var xw:Int = x + param.w;
		var yh:Int = y + param.h;
		
		var tx:Int = param.tx;
		var ty:Int = param.ty;
		var txw:Int = tx + param.tw;
		var tyh:Int = ty + param.th;
		
		buffFull.setByteOffset( 0 );
		
		buffFull.write_2_Short( xw, yh );                          // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( txw, tyh );                        // TEXT COORD 
		
		buffFull.write_2_Short( xw, yh );                          // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( txw, tyh );                        // TEXT COORD 
		
		buffFull.write_2_Short( x, yh );                           // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( tx, tyh );                         // TEXT COORD 
		
		buffFull.write_2_Short( xw, y );                           // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( txw, ty );                         // TEXT COORD 
		
		buffFull.write_2_Short( x, y );                            // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( tx, ty );                          // TEXT COORD 
		
		buffFull.write_2_Short( x, y );                            // VERTEX_POSITION_START
		if (type & DType.ZINDEX != 0) buffFull.write_1_Float( param.z ); // Z INDEX
		if (type & DType.RGBA   != 0) buffFull.write_1_UInt( param.rgba ); // RGBA
		buffFull.write_2_Short( tx, ty );                          // TEXT COORD 
		
		buffFull.setByteOffset( 0 );
		
		GL.bindBuffer (GL.ARRAY_BUFFER, glBuff);
		GL.bufferSubData(GL.ARRAY_BUFFER, buf_pos * VERTEX_STRIDE , buffFull.dataView);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
	}


	/*
	public inline function setTexCoord(e:I_Element, param:Param):Void
	{
		var buf_pos:Int = e.buf_pos;
		
		var tx:Int = param.tx;
		var ty:Int = param.ty;
		var txw:Int = tx + param.tw;
		var tyh:Int = ty + param.th;
		
		
		
		bufferDataTex( buffTex_0, 
			txw, tyh	// TEXT COORD twice
		);
		bufferDataTex( buffTex_1, 
			tx, tyh		// TEXT_COORD
		);	
		bufferDataTex( buffTex_2, 
			txw, ty			// TEXT_COORD
		);	
		bufferDataTex( buffTex_3, 
			tx,  ty			// TEXT_COORD twice
		);				
		GL.bindBuffer (GL.ARRAY_BUFFER, glBuff);
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos  ) * VERTEX_STRIDE + TEX_OFFSET, buffTex_0.dataView );
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos+1) * VERTEX_STRIDE + TEX_OFFSET, buffTex_0.dataView );
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos+2) * VERTEX_STRIDE + TEX_OFFSET, buffTex_1.dataView );
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos+3) * VERTEX_STRIDE + TEX_OFFSET, buffTex_2.dataView );
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos+4) * VERTEX_STRIDE + TEX_OFFSET, buffTex_3.dataView );
		GL.bufferSubData( GL.ARRAY_BUFFER, (buf_pos+5) * VERTEX_STRIDE + TEX_OFFSET, buffTex_3.dataView );
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
	}
	*/
	
	// ----------------------------------------------------------------------------------
	public inline function getDefaultFragmentShaderSrc():String
	{
		return(ElementSimpleBuffer.defaultFragmentShaderSrc);
	}
	
	public inline function getDefaultVertexShaderSrc():String
	{
		return(ElementSimpleBuffer.defaultVertexShaderSrc);
	}
	
	// ----------------------------------------------------------------------------------
	
	public static inline var defaultVertexShaderSrc:String =
	"	precision mediump float;

		// always twice if time dependend
		attribute vec2 aPosition;
		
		#if_ZINDEX
		attribute float aZindex;
		#end_ZINDEX
		attribute vec2 aTexCoord;
		
		#if_RGBA
		attribute vec4 aRGBA;
		varying vec4 vRGBA;
		#end_RGBA

		varying vec2 vTexCoord;
		
		uniform float uTime;
		uniform float uZoom;
		uniform vec2 uResolution;
		uniform vec2 uDelta;
		
		void main(void) {
			#if_RGBA
			vRGBA = aRGBA.wzyx;
			#end_RGBA
			
			vTexCoord = aTexCoord;
						
			float zoom = uZoom;
			float width = uResolution.x;
			float height = uResolution.y;
			float deltaX = floor(uDelta.x);
			float deltaY = floor(uDelta.y);
			
			float right = width-deltaX*zoom;
			float left = -deltaX*zoom;
			float bottom = height-deltaY*zoom;
			float top = -deltaY * zoom;
			
			gl_Position = mat4 (
				vec4(2.0 / (right - left)*zoom, 0.0, 0.0, 0.0),
				vec4(0.0, 2.0 / (top - bottom)*zoom, 0.0, 0.0),
				vec4(0.0, 0.0, -0.001, 0.0),
				vec4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), 0.0, 1.0)
			)
			* vec4 (aPosition ,
				#if_ZINDEX
				aZindex
				#else_ZINDEX
				0.0
				#end_ZINDEX
				, 1.0
				);
		}
	";
	
	public static inline var defaultFragmentShaderSrc:String =
	"	precision mediump float;
		varying vec2 vTexCoord;
		#if_RGBA
		varying vec4 vRGBA;
		#end_RGBA
		uniform sampler2D uImage;
		
		uniform vec2 uMouse, uResolution;
		
		void main(void)
		{
			vec4 texel = texture2D(uImage, vTexCoord / #MAX_TEXTURE_SIZE );
			if(texel.a < 0.5) discard;
			#if_RGBA
			gl_FragColor = texel * vRGBA;
			#else_RGBA
			gl_FragColor = texel;
			#end_RGBA
		}
	";

}