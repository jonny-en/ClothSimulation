'use stric';

var BallThrower = function BallThrower(posX, posY, posZ, ballRadius, scene, renderer) {
		// =======================================================================// 
		// Initialising						        				     		  //
		// =======================================================================//
		var TEX_SIZE = 4;
		var ballsThrown = 0;

		this.spheres = [];
		this.scene = scene;
		this.origin = new THREE.Vector3( posX, posY, posZ );

		this.gpuCompute = new GPUComputationRenderer(TEX_SIZE, TEX_SIZE, renderer);

		var dtPosition = this.gpuCompute.createTexture();
		fillPositionTexture(dtPosition, this.origin);

		this.positionVariable = this.gpuCompute.addVariable("texturePosition", shaders.fs.POS_BALLS, dtPosition);
		this.oldPositionVariable = this.gpuCompute.addVariable("textureOldPosition", shaders.fs.OLDPOS_BALLS, dtPosition);

		this.gpuCompute.setVariableDependencies( this.positionVariable, [ this.positionVariable, this.oldPositionVariable ] );
		this.gpuCompute.setVariableDependencies( this.oldPositionVariable, [ this.positionVariable, this.oldPositionVariable ]);

		this.positionVariable.wrapS = THREE.RepeatWrapping;
		this.positionVariable.wrapT = THREE.RepeatWrapping;
		this.oldPositionVariable.wrapS = THREE.RepeatWrapping;
		this.oldPositionVariable.wrapT = THREE.RepeatWrapping;

		this.positionUniforms = this.positionVariable.material.uniforms;
		this.positionUniforms.time = { value: 0.0 };
		this.positionUniforms.delta = { value: 0.0 };
		this.positionUniforms.newBallIndex = {value: -1};
		this.positionUniforms.originX = {value: this.origin.x};
		this.positionUniforms.originY = {value: this.origin.y};
		this.positionUniforms.originZ = {value: this.origin.z};		

		var error = this.gpuCompute.init();
		if( error !== null){
			console.error(error);
		}
		

		// =======================================================================// 
		// Update function					        				     		  //
		// =======================================================================//
		BallThrower.prototype.update = function(now, delta){
			//Update Uniforms
			this.positionUniforms.time.value = now;
			this.positionUniforms.delta.value = delta;
			//Compute new Values
			this.gpuCompute.compute();

			//Draw new Values
			var newPos = new Float32Array(this.positionVariable.initialValueTexture.image.width * this.positionVariable.initialValueTexture.image.height * 4);
			var target = this.gpuCompute.getCurrentRenderTarget( this.positionVariable );
			renderer.readRenderTargetPixels(target,0,0,this.positionVariable.initialValueTexture.image.width,this.positionVariable.initialValueTexture.image.height, newPos);
			for(var i = 0; i < newPos.length && i/4 < this.spheres.length; i+=4){
				this.spheres[i/4].position.set(newPos[ i+0 ],newPos[ i+1 ],newPos[ i+2 ]);
			}
			this.positionUniforms.newBallIndex.value = -1;

		};

		BallThrower.prototype.throwBall = function(){
			var newIndex = ballsThrown%(TEX_SIZE*TEX_SIZE);
			if(ballsThrown < TEX_SIZE*TEX_SIZE){
				addSphere(this.spheres,this.scene,this.origin);
			}
				this.positionUniforms.newBallIndex.value = newIndex;
				ballsThrown++;
		}

		// =======================================================================// 
		// Intern functions	(no access from outside)				     		  //
		// =======================================================================//
		function fillPositionTexture(texture, position){
			tData = texture.image.data;
			for(var i=0;  i < tData.length-3; i += 4){
				tData[ i+0 ] = position.x;
				tData[ i+1 ] = position.y;
				tData[ i+2 ] = position.z;
				tData[ i+3 ] = -1.0;
 			}
		}

		function addSphere(array, scene, position){
			var geometry = new THREE.SphereGeometry( ballRadius, 20, 20); 
			var material = new THREE.MeshBasicMaterial(0xffffff);
			var sphere = new THREE.Mesh( geometry, material);
			sphere.position.set(position.x,position.y,position.z);
			array.push(sphere);
			scene.add(sphere);
		}


};
