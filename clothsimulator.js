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

		window.addEventListener("mousedown", onMouseDown.bind(this), false);


		this.scene = new THREE.Scene();
		this.scene.background = new THREE.Color( 0x111111 );

		this.renderer = new THREE.WebGLRenderer({antialias: true});
		this.renderer.setPixelRatio( window.devicePixelRatio );
		this.renderer.setSize( window.innerWidth, window.innerHeight );
		this.renderer.shadowMap.enabled = true;
		this.renderer.shadowMap.type = THREE.BasicShadowMap;
		//this.renderer.shadowMap.renderSingleSided = false;
		this.canvas.appendChild( this.renderer.domElement );

		var lightFL = new THREE.PointLight( 0xffffff, .7);
		lightFL.position.set(-30,0,30);
		lightFL.castShadow = true;
		lightFL.shadow.camera.near = 10;
		lightFL.shadow.camera.far = 100;
		this.scene.add(lightFL);

		var lightFR = new THREE.PointLight( 0xffffff, .5);
		lightFR.position.set(30,0,30);
		lightFR.castShadow = true;
		lightFR.shadow.camera.near = 10;
		lightFR.shadow.camera.far = 100;
		this.scene.add(lightFR);

		var lightB = new THREE.PointLight( 0xffffff, .6 );
		lightB.position.set(-90,0,-90);
		this.scene.add(lightB);


		this.cloth = new Cloth(50,50,CLOTH_SIZE,CLOTH_SIZE, this.renderer);
		this.scene.add(this.cloth.object);

		this.ballthrower = new BallThrower(0, 0, 50, 2, this.scene, this.renderer);
		this.raycaster = new THREE.Raycaster();
		this.mouse = new THREE.Vector2();

		this.last = 0;
		this.now = 0;


		this.gui = new dat.GUI();
		this.gui.add(this.cloth.object.material, 'wireframe');
		this.gui.addColor(this.cloth, 'color'); 
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
			this.ballthrower.update(this.now, this.delta);
		};

		ClothSimulator.prototype.updateTime = function(){
			this.now = performance.now();
			this.delta = (this.now - this.last)/ 1000;
			//Safety cap on large deltas
			if(this.delta > 1){
				this.delta = 1;
			}
		};

		function onMouseDown(event){
   			this.mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
   			this.mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;
   			this.raycaster.setFromCamera(this.mouse, this.camera);
   			var intersect = this.raycaster.intersectObject( this.cloth.object );
   			if(intersect.length != 0){
   				this.ballthrower.throwBallTo(intersect[0].point);
   			}
		};
};
