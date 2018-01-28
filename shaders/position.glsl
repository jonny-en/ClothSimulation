uniform float time;
uniform float delta;
uniform float DAMPING;	// Damping coefficent

uniform float mass;
uniform float gravity;
uniform float KsStructur, KdStructur; //Spring coefficents

// find neighbor for springforce calculation
vec2 getNeighbor(int n, out float ks, out float kd){
	if(n<4){
		ks = KsStructur;
		kd = KdStructur;
	}

	if(n == 0){
			return vec2(1,0);
	}
	if(n == 1){
			return vec2(0,-1);
	}
	if(n ==2){
			return vec2(-1,0);
	}
	if(n == 3){
			return vec2(0,1);

		}
}

void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
	vec3 gravityVec = vec3(0.0,-0.00981,0.0);
	vec3 velocity = (position - oldPosition) / delta;
	float ks = 0.0, kd=0.0;

	//fix top row so it does not move
	if(uv.y == 1.0/(2.0*resolution.y)){
		ownMass = 0.0;
		velocity = vec3(0.0);
	}
	vec3 force = gravityVec*ownMass + velocity*DAMPING;


//Calculating springforces (NOT WORKING)
	/*for (int k = 0; k < 4; k++){
		vec2 coord = getNeighbor(k, ks, kd);
		float i = coord.x;
		float j = coord.y;

		vec2 coordNeighbor = vec2(uv.x + coord.x*1.0/resolution.x, uv.y + coord.y*1.0/resolution.x);
		vec2 inv_cloth = vec2(4.0,4.0);
		float rest_length = length(coord*inv_cloth);

		vec3 p2 = texture2D(texturePosition, coordNeighbor).xyz;
		vec3 v2 = (p2 - texture2D(textureOldPosition, coordNeighbor).xyz)/delta;
		vec3 deltaP = position - p2;
		vec3 deltaV = velocity - v2;
		float dist = length(deltaP);
		if(dist > 1.0){
			dist = 1.2;
		}

		float leftTerm = -ks * (dist-rest_length);
		float rightTerm = kd * (dot(deltaV, deltaP)/dist);
		vec3 springForce = (leftTerm + rightTerm)*normalize(deltaP);
		force += springForce;
	}
*/
vec3 acceleration = vec3(0.0);
if(ownMass > 0.0){
	 acceleration = force/ownMass;
}

	vec3 newPosition =  position * 2.0 - oldPosition + acceleration * delta *delta;

	gl_FragColor = vec4(newPosition, 1 );
}
