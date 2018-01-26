'use strict';

var ClothSimulator = function ClothSimulator(canvas) {

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
		
		var geometry = new THREE.PlaneBufferGeometry( 40, 40, 8 ,8);
		var material = new THREE.MeshBasicMaterial( {wireframe: true, color: 0xffff00, side: THREE.DoubleSide} );
		this.cloth = new THREE.Mesh( geometry, material );
		this.scene.add(this.cloth);

 		console.log(this.cloth);
		
		// =======================================================================// 
		// Method: Run the Simulator		        				     		  //
		// =======================================================================//
		ClothSimulator.prototype.run = function(){
			this.renderLoop();
		}
		
		// =======================================================================// 
		// Method: RenderLoopFunction        						     		  //
		// =======================================================================//
		ClothSimulator.prototype.renderLoop = function(){
			this.update();
			this.render();
			var that = this;
			requestAnimationFrame(function(){that.renderLoop()});
		}
		
		// =======================================================================// 
		// Method: Render The Scene   	     						     		  //
		// =======================================================================//
		ClothSimulator.prototype.render = function(){
			this.renderer.render(this.scene, this.camera);
		}

		// =======================================================================// 
		// Method: Update all Variables	     						     		  //
		// =======================================================================//
		ClothSimulator.prototype.update = function(){
			//do sth
		}
};


