'use stric';

var Cloth = function Cloth(width, height, segmentsX, segmentsY, renderer) {
		// =======================================================================// 
		// Initialising						        				     		  //
		// =======================================================================//
		
		//Init Cloth-Object
		var geometry = new THREE.PlaneBufferGeometry( width, height, segmentsX ,segmentsY);
		var material = new THREE.MeshBasicMaterial( {wireframe: true, color: 0xffff00, side: THREE.DoubleSide} );
		this.object = new THREE.Mesh( geometry, material );

		//Setup ComputationRenderer
		this.gpuCompute = new GPUComputationRenderer(segmentsX+1, segmentsY+1, renderer);

		//Init Textures used for computation
		var dtPosition = this.gpuCompute.createTexture();
		var dtVelocity = this.gpuCompute.createTexture();
		fillPositionTexture(dtPosition, this.object.geometry.attributes.position.array);

		//Init Variables with corresponding Shader
		this.positionVariable = this.gpuCompute.addVariable("texturePosition", shaders.fs.POS, dtPosition);
		this.velocityVariable = this.gpuCompute.addVariable("textureVelocity", shaders.fs.VEL, dtVelocity);

		this.velocityVariable.wrapS = THREE.RepeatWrapping;
		this.velocityVariable.wrapT = THREE.RepeatWrapping;
		this.positionVariable.wrapS = THREE.RepeatWrapping;
		this.positionVariable.wrapT = THREE.RepeatWrapping;

		//Set Variable Dependencies
		this.gpuCompute.setVariableDependencies( this.velocityVariable, [ this.positionVariable, this.velocityVariable ] );
		this.gpuCompute.setVariableDependencies( this.positionVariable, [ this.positionVariable, this.velocityVariable ] );

		//Init Uniform Values
		this.positionUniforms = this.positionVariable.material.uniforms;
		this.velocityUniforms = this.velocityVariable.material.uniforms;
		this.positionUniforms.time = { value: 0.0 };
		this.positionUniforms.delta = { value: 0.0 };
		this.velocityUniforms.time = { value: 1.0 };
		this.velocityUniforms.delta = { value: 0.0 };

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
			var newPos = new Float32Array(64 * 4);
			var target = this.gpuCompute.getCurrentRenderTarget( this.positionVariable );
			renderer.readRenderTargetPixels(target,0,0,8,8, newPos);
			
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
			for(var i=0;  i < tData.length; i += 4){
				tData[ i+0 ] = data[ i+0 - (i/4) ];
				tData[ i+1 ] = data[ i+1 - (i/4) ];
				tData[ i+2 ] = data[ i+2 - (i/4) ];
				tData[ i+3 ] = 1
 			}
		}
};
