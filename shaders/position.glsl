uniform float time;
uniform float delta;
uniform float DAMPING;	// Damping coefficent

uniform float mass;
uniform float gravity;
uniform float KsStructur, KdStructur, KsShear, KdShear, KsBend, KdBend; //Spring coefficents

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
			//shear springs (diagonal neighbors)
				//     o  o  o
				//      \   /
				//     o  m  o
				//      /   \
				//     o  o  o
				if(n<8) {
			       ks = KsShear;
			       kd = KdShear;
			   }
				if (n == 4) return vec2( 1,  -1);
				if (n == 5) return vec2( -1, -1);
				if (n == 6) return vec2(-1,  1);
				if (n == 7) return vec2( 1,  1);

				//bend spring (adjacent neighbors 1 node away)
				//
				//o   o   o   o   o
				//        |
				//o   o   |   o   o
				//        |
				//o-------m-------o
				//        |
				//o   o   |   o   o
				//        |
				//o   o   o   o   o
				if(n<12) {
			       ks = KsBend;
			       kd = KdBend;
			   }
				if (n == 8)	return vec2( 2, 0);
				if (n == 9) return vec2( 0, -2);
				if (n ==10) return vec2(-2, 0);
				if (n ==11) return vec2( 0, 2);
		}
}

void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
	vec3 gravityVec = vec3(0.0,-0.000981,-0.0001);
	vec3 velocity = (position - oldPosition) / delta;
	float ks = 0.0, kd=0.0;
	vec2 inv_size = vec2(4.0/resolution.x,4.0/resolution.y);

	//fix top row so it does not move
	// if((uv.y == 1.0/(2.0*resolution.y)) || (uv.y == 1.0 - 1.0/(2.0*resolution.y))){
	// 	ownMass = 0.0;
	// }



	vec3 force = gravityVec*ownMass + velocity*DAMPING;

vec3 deltaP;
float s;
vec3 t;
	for (int k = 0; k < 12; k++)
		{
			vec2 coord = getNeighbor(k, ks, kd);
			float j = coord.x;
			float i = coord.y;



vec2 coordNeighbor = vec2(uv.x + coord.x*(1.0/resolution.y), uv.y + coord.y*(1.0/resolution.y));
if(coordNeighbor.x < 1.0/2.0*resolution.x || coordNeighbor.y <1.0/2.0*resolution.y ||
	coordNeighbor.x > 1.0 - 1.0/2.0*resolution.x || coordNeighbor.y >1.0 - 1.0/2.0*resolution.y){
		force += 0.0;
	}
else {
float restLength = length(coord)*3.3333;
vec3 p2 = texture2D(texturePosition, coordNeighbor).xyz;
vec3 v2 = (p2 - texture2D(textureOldPosition, coordNeighbor).xyz)/delta;
 deltaP = position - p2;
vec3 deltaV = velocity - v2;
float dist = length(deltaP);

float leftTerm = -ks * (dist-restLength);
float rightTerm = kd * (dot(deltaV, deltaP)/dist);
vec3 springForce = (leftTerm + rightTerm)*normalize(deltaP);

force += springForce;
}
}
//Calculating springforces (NOT WORKING)
	/*for (int k = 0; k < 4; k++){
		vec2 coord = getNeighbor(k, ks, kd);
		float i = coord.x;
		float j = coord.y;

		vec2 coordNeighbor = vec2(uv.x + coord.x*1.0/resolution.x, uv.y + coord.y*1.0/resolution.x);
		float rest_length = 3.3333;

		vec3 p2 = texture2D(texturePosition, coordNeighbor).xyz;
		vec3 v2 = (p2 - texture2D(textureOldPosition, coordNeighbor).xyz)/delta;
		vec3 deltaP = position - p2;
		vec3 deltaV = velocity - v2;
		float dist = length(deltaP);
		if(dist > 3.5){
			dist = 3.5;
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
if(position.y < -25.0){
	position.y = -25.0;
}



	vec3 newPosition =  (position * 2.0 - oldPosition + acceleration * delta *delta);
	//restrict bending

		gl_FragColor = vec4(newPosition,1 );
}
