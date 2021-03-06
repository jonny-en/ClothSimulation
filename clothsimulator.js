'use strict';

var ClothSimulator = function ClothSimulator(canvas) {
		// =======================================================================// 
		// Constants     					        				     		  //
		// =======================================================================//

		//Cloth Size. Amount of Vectors will be size*size. Should be power of 2.
		var CLOTH_SIZE = 16;
		
		// =======================================================================// 
		// Initialising						        				     		  //
		// =======================================================================//

		this.canvas = canvas;
		this.camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 1, 3000 );
		this.camera.position.z = 60;
		
		this.controls = new THREE.OrbitControls(this.camera);
		
		this.scene = new THREE.Scene();
		this.scene.background = new THREE.Color( 0x111111 );

		this.renderer = new THREE.WebGLRenderer();
		this.renderer.setPixelRatio( window.devicePixelRatio );
		this.renderer.setSize( window.innerWidth, window.innerHeight );
		this.canvas.appendChild( this.renderer.domElement );
		
		this.cloth = new Cloth(50,50,CLOTH_SIZE,CLOTH_SIZE, this.renderer);
		this.scene.add(this.cloth.object);

		this.last = 0;
		this.now = 0;

		// =======================================================================// 
		// Method: Run the Simulator		        				     		  //
		// =======================================================================//
		ClothSimulator.prototype.run = function(){
			this.renderLoop();
		};
		
		// =======================================================================// 
		// Method: RenderLoopFunction        						     		  //
		// =======================================================================//
		ClothSimulator.prototype.renderLoop = function(){
			this.render();
			this.update();
			var that = this;
			requestAnimationFrame(function(){
				that.renderLoop()
			});
		};
		
		// =======================================================================// 
		// Method: Render The Scene   	     						     		  //
		// =======================================================================//
		ClothSimulator.prototype.render = function(){
			this.renderer.render(this.scene, this.camera);
		};

		// =======================================================================// 
		// Method: Update all Variables	     						     		  //
		// =======================================================================//
		ClothSimulator.prototype.update = function(){
			this.updateTime();
			this.cloth.update(this.now, this.delta);
		};

		ClothSimulator.prototype.updateTime = function(){
			this.now = performance.now();
			this.delta = (this.now - this.last)/ 1000;
			//Safety cap on large deltas
			if(this.delta > 1){
				this.delta = 1;
			}
		};
};


