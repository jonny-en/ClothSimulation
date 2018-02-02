'use stric';

var Cloth = function Cloth(width, height, vertsX, vertsY, renderer) {
		// =======================================================================//
		// Initialising						        				     		  //
		// =======================================================================//

		//Init Cloth-Object
		var facesX = vertsX-1;
		var facesY = vertsY -1;
		var geometry = new THREE.PlaneBufferGeometry( width, height, facesX ,facesY);
		var material = new THREE.MeshPhongMaterial( {wireframe: false, color: 0xffff00, side: THREE.DoubleSide} );
		this.object = new THREE.Mesh( geometry, material );
		this.object.receiveShadow = true;
		this.object.castShadow = true;
		//Setup ComputationRenderer
		this.gpuCompute = new GPUComputationRenderer(vertsX, vertsY, renderer);

		//Init Textures used for computation
		var dtPosition = this.gpuCompute.createTexture();
		var dtOldPosition = this.gpuCompute.createTexture();
		fillPositionTexture(dtPosition, this.object.geometry.attributes.position.array);
		fillPositionTexture(dtOldPosition, this.object.geometry.attributes.position.array);
		//Init Variables with corresponding Shader
		this.positionVariable = this.gpuCompute.addVariable("texturePosition", shaders.fs.POS, dtPosition);
		this.oldPositionVariable = this.gpuCompute.addVariable("textureOldPosition", shaders.fs.OLD_POS, dtOldPosition);

		this.oldPositionVariable.wrapS = THREE.RepeatWrapping;
		this.oldPositionVariable.wrapT = THREE.RepeatWrapping;
		this.positionVariable.wrapS = THREE.RepeatWrapping;
		this.positionVariable.wrapT = THREE.RepeatWrapping;

		//Set Variable Dependencies
		this.gpuCompute.setVariableDependencies( this.oldPositionVariable, [ this.positionVariable, this.oldPositionVariable ] );
		this.gpuCompute.setVariableDependencies( this.positionVariable, [ this.positionVariable, this.oldPositionVariable ] );

		//Init Uniform Values
		this.positionUniforms = this.positionVariable.material.uniforms;
		this.positionUniforms.time = { value: 0.0 };
		this.positionUniforms.delta = { value: 0.0 };
		this.positionUniforms.mass = {value: 1.0};
		this.positionUniforms.gravity = {value: -0.00981};
		this.positionUniforms.DAMPING = {value: -0.0125};
		

		var restX = width/facesX;
		var restY = width/facesY;
		var restDiagonal = Math.sqrt( restX * restX + restY * restY);
		console.log(restDiagonal);
		this.positionUniforms.restLenghts = {type: "v3", value: new THREE.Vector3( restX, restY, restDiagonal)};

		//Init ComputationRenderer
		var error = this.gpuCompute.init();
		if( error !== null){
			console.error(error);
		}

		// =======================================================================//
		// Update function					        				     		  //
		// =======================================================================//
		Cloth.prototype.update = function(now, delta){
			//Update Uniforms
			this.positionUniforms.time.value = now;
			this.positionUniforms.delta.value = delta;

			//Compute new Values
			this.gpuCompute.compute();

			//Draw new Values
			var newPos = new Float32Array(this.positionVariable.initialValueTexture.image.width * this.positionVariable.initialValueTexture.image.height * 4);
			var target = this.gpuCompute.getCurrentRenderTarget( this.positionVariable );
			renderer.readRenderTargetPixels(target,0,0,this.positionVariable.initialValueTexture.image.width,this.positionVariable.initialValueTexture.image.height, newPos);
			for(var i=0; i < this.object.geometry.attributes.position.array.length-2; i += 3){
				this.object.geometry.attributes.position.array[ i+0 ] = newPos[ i+0 + i/3];
				this.object.geometry.attributes.position.array[ i+1 ] = newPos[ i+1 + i/3];
				this.object.geometry.attributes.position.array[ i+2 ] = newPos[ i+2 + i/3];
 			}
 			this.object.geometry.attributes.position.needsUpdate = true;
		};


		// =======================================================================//
		// Helper-functions	(not part of object)       				     		  //
		// =======================================================================//

		//This functions fills the positionTexture with the start vertices of the BufferObject.
		function fillPositionTexture(texture, data){
			tData = texture.image.data;
			for(var i=0;  i < tData.length-3; i += 4){
				tData[ i+0 ] = data[ i+0 - (i/4) ];
				tData[ i+1 ] = data[ i+1 - (i/4) ];
				tData[ i+2 ] = data[ i+2 - (i/4) ];
				tData[ i+3 ] = 1
 			}
		}
};
