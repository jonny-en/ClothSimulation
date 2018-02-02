uniform float time;
uniform float delta;

uniform float newBallIndex;

uniform vec3 origin;

uniform vec3 destination;

void main()	{
	
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	float w = texture2D( texturePosition, uv ).w;


	float uNew = mod(newBallIndex,resolution.x) / (resolution.x) + 1./(2.*resolution.x);
	float vNew = (floor(newBallIndex / (resolution.y))) / (resolution.y) + 1./(2.*resolution.x);
	
	bool sameU = (uv.x == uNew);
	bool sameV = (uv.y == vNew);
	if(sameU && sameV){
	 	position = vec3(origin.x,origin.y,origin.z);
	 	w = -1.;
	}
	else{
		if( w == 1.){
			float mass = 30.;
			vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
			vec3 gravity = vec3(0.,-0.00981,0.);
			position =  position * 2.0 - oldPosition + gravity * delta * delta;
		}
		else{
			float throwVectorY =  0.0;
			position =  position + vec3((destination.x-origin.x)/50.,(destination.y-origin.y)/60.+.2,(destination.z-origin.z)/50.);
		}
		w = 1.;
	}


	gl_FragColor = vec4(position, w );
}