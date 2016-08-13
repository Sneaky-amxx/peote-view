###Peote View - 2D OpenGL Render Library

This library is written with the syntactic sugar of [Haxe](http://haxe.org),  
together with power of great [Lime](https://github.com/openfl/lime) multiplatform work.  

To use from javascript look here -> [peoteView.js](https://github.com/maitag/peoteView.js).  

####Build [Samples (^_^) <-](http://maitag.github.io/peote-view/)

- check: [peoteView.lime](https://github.com/maitag/peote-view/blob/master/peoteView.lime#L10) to see what will be compiled
- build: `lime build peoteView.lime linux` ( | html5 | windows | android | raspi | rpi | ...)
- start new sample and play around


####Why this tool ?

- handle imagedata and procedural shadercode equally
- the power of haxe-lime multiplatform code generation ( haxe -> cpp+js+.+..+... )
- better sync over network by element-indices (to avoid deep object-serialization)
- simplifying opengl-usage (using power of 3d accelerated hardware in other Dimensions;)
- transition-rendering by gpu to reduce datatransfer (more time for game-logic on cpu)


####How to use

```
"Displaylist"  contains much "Element"  
"Element"      is defined by "Program"  
"Program"      "Texture" and Shadercode
"Texture"      acts as image-cache
"Image"        to load into "Texture"-Slot  
```

#####0) Initialize
```
	peoteView = new PeoteView({
		
		maxDisplaylists:    10,
		maxPrograms:        50,
		maxTextures:        50,
		maxImages:         100
		// TODO: onError:    function(errorcode, msg) {}
	});
```



You will be able to display "massive" graphic elements and use your own shadercode
for variation, animation or combining Imagedata!

To be near OpenGl - all items are numbered - to speed up rendering.


step by step:

	

#####1) Textures

A Texture reserves space on GPU-Ram for storing Images into same sized Slots.

```
	// --------------------- TEXTURE -------------------- //
	
	peoteView.setTexture({ 

		texture: 0,       // texture index
	
		slots: 16,        // minimum amount of slots to reserve ( default is 1 )

		w:     512,       // slot width
		h:     512,       // slot height
	});
```	
	
Created Texturesize depends on Hardware (2048 up to 16384) and will be power of 2.
Check peoteView.MAX_TEXTURE_SIZE to see whats possible on your hardware.



#####2) Image-Data

Images holds url- or file-referenz, where imagedata will be "load on demand", so
if some element use an image, it's data will be load into free Image-Slot of assigned Texture.
```
	// --------------------- IMAGE ----------------------- //
	
	peoteView.setImage({

		image:   0,                    // image index
	
		texture: 0,                    // texture to store image-data inside

		filename: "assets/font.png",   // image filename or url to load image from

		preload: true ,                // load images into texture, no matter of usage 
		                               // default behaivor: Image is loaded on first use of element
		
		// cache: true,                // (TODO) loaded imagedata will be cached (outside gpu-texture-ram)
		
		
		// to disable automatic insert into free texture-slot:
		// ---------------------------------------------------
		
		slot: 0,                      // manual set texture-slot to load image in
                                      // all images of same texture should define or not define this parameter
		
		
		// image fitting and aligning inside texture-slot:
		// -----------------------------------------------
		
		fit: "in",               // "in", "out" or "exact" fitting loaded image into slot size
		// align: "top"          // (TODO) "top left" and such things
		// scaleUp  :  false,    // (TODO) only scale down (images smaller than size of texture-slot dont scale up) 
		// rgba: 0xff0022ff;     // (TODO) background color for border if not exactly fit
		
		
		// posit directly inside texture-slot to create own texture-atlas:
		// ---------------------------------------------------------------
		
		keep: true,         // keep existing pixels in slot if image is smaller that slot-size
		x:  10,             // Position from left
		y:  10,             // Position from right
		w: 100,             // new image width
		h: 100,             // new image height

		// callbacks (TODO)
		onLoad:     function(w,h) {},         // callback if image is loaded
		onProgress: function(p) {},           // callback while image loads
		onError:    function(error, msg) {},  // callback on loading error -> eorror==0 -> no free texture slot
		
	});
	
```



#####3) Program (GPU-Shader)

opengl-shadercode and textures that can be use

```
	var iteration  = [10];
	var somefloats = [2.0, 3.14, 4.1];
	
	// --------------------- PROGRAM --------------------------- //
	peoteView.setProgram({

		program: 0,                           // program index
	
		vshader: "assets/lyapunov_01.vert",   // custom vertex shader
		fshader: "assets/lyapunov_01.frag",   // custom fragment shader
		
		texture: 0,                           // all images stored inside this texture can be used

		// textures:[0,2,1,4]                 // to combine multiple textures with own shadercode
		                                      // max 7 aditional textures available per program
		
		vars: [ "iteration" => iteration,     // custom uniform variable bindings for this program
		        "somefloat" => somefloats
		      ]
	});
```




#####4) Displaylist

rectangular screen-areas to display lots of elements

```
	// ------------------------- DISPLAYLIST -------------- //

	peoteView.setDisplaylist({

		displaylist: 0,                          // displaylist index
		
		type:DisplaylistType.RGBA,               // can be combination of .PICKING  .ANIM   .ROTATION...
		
		maxElements:    100,                     // maximum elements to display
		maxPrograms:     10,                     // maximum different shader-programs
		bufferSegments:  10,                     // gpu-buffer segmentation (can be result in better performance for I/O)
		
		x: 150,                                  // pixels from left border
		y: 50,                                   // pixels from top border
		w: 1000,                                 // width
		h: 1000,                                 // height
		z: 0,
		
		renderToTexture: 0, // TODO: texture to render content in
		
		enable: true
	});
```



#####5) Element

little Graphic inside Displaylist-Area (like a c64-sprite)

```
	// ----------------------- ELEMENT --------------------- //
	
	peoteView.setElement({

		element: 0,      // element index

		displaylist: 0,  // displaylist to put in
		
		program: 0,      // shader (+texture) to use
		
		// Texture Mapping ---------------
		
		image: 0,        // image number from texture
		// slot: 0,      // or set texture-slot manual
		                 // without image+slot parameter -> full texturespace
		
		tile:  0,        // (0..255) texture coordinates will be splittet into 16x16 tiles
		
		// tx, ty, -> manual setting texture-coordinates shifting
		// tw ,th  -> manual setting texture-coordinates size
		
		// Position and Size ---------------
		
		x: 10,  // pixels from left displaylist border
		y: 10,  // pixels from top displaylist border
		w: 100, // width
		h: 100, // height
		z: 0    // z-order   ( 0 <= z <= 32767 )
		
		// (rotation, animation, coloring ... -> see samples)
	});
```



#####How to optimize render-loop:

- order displaylists functional:
	1) game-gfx 
	2) user-interface (DisplaylistType.PICK to interact with Elements)
	
- elements with same program will be drawn fastest (throught opengl drawarray)
- use only 1 bufferSegment in Displaylist if there is only one program ;)



####Todo

- image alignment inside texture-slot
- render to texture
- more simple samples, usability and platform tests, api improvement, optimization
- tile animation on gpu
- more demos ;)
- documentation



