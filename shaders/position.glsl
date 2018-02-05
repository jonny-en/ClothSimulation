uniform float time;
uniform float delta;
uniform float DAMPING;	// Damping coefficent

uniform float mass;
uniform float gravity;
uniform vec3 restLengths; //Spring coefficents
uniform vec2 pinned[ 2 ]; // Fixed Points

//Calculate corretion of one point to antother
vec3 calculateTranslation(vec3 p1, vec2 neighborCoord ,float restLength){
	vec3 p2 = texture2D(texturePosition, neighborCoord/resolution.xy).xyz;
	vec3 dist = p1 - p2;
	float dAbs = distance(p1,p2);
	float s = 0.;
	if(dAbs != 0.){
	s = (restLength - dAbs)/dAbs;
	}
	//Fix translation for top row
	float factor = 0.5;
	for(int i = 0; i< 2; i++){
		if(neighborCoord.y == pinned[i].y + 0.5 && neighborCoord.x == pinned[i].x + 0.5){
			factor = 1.;
		}
	}

	vec3 t = dist * factor  * s;

	return t;
}


//check, if contraints are broken and apply correction
vec3 checkConstraints(vec2 coord, vec3 position){
	vec2 neighborCoords[16];
	 neighborCoords[0] = vec2(1.,0.);
	 neighborCoords[1] = vec2(0.,1.);
	 neighborCoords[2] = vec2(-1.,0.);
	 neighborCoords[3] = vec2(0.,-1.);
	 neighborCoords[4] = vec2(1., -1.);
	 neighborCoords[5] = vec2(1.,1.);
	 neighborCoords[6] = vec2(-1.,1.);
	 neighborCoords[7] = vec2(-1.,-1.);
	 neighborCoords[8] = vec2(2.,0.);
	 neighborCoords[9] = vec2(0.,2.);
	 neighborCoords[10] = vec2(-2.,0.);
	 neighborCoords[11] = vec2(0.,-2.);
	 neighborCoords[12] = vec2(2.,-2.);
	 neighborCoords[13] = vec2(2.,2.);
	 neighborCoords[14] = vec2(-2.,2.);
	 neighborCoords[15] = vec2(-2.,-2.);

	vec3 t = vec3(0.0);
	vec3 p2 = position;
vec3 neighbors[16];
	for(int i = 0; i < 16; i++){
		neighbors[i].xy = vec2(0.0,0.0);
	}
	for(int i = 0; i < 16; i++){
		float tempX = coord.x + neighborCoords[i].x;
		float tempY = coord.y + neighborCoords[i].y;
		vec2 neighbor = vec2(tempX,tempY);

		if(tempX >= 0.5 && tempX <= resolution.x - 0.5 && tempY >= 0.5 && tempY <= resolution.y - 0.5 ){

			if(i < 4){
				if(!(neighborCoords[i].x == 0.)){
					neighbors[i] = vec3(neighbor,restLengths.x);
				}else {
					neighbors[i] = vec3(neighbor,restLengths.y);
				}
			}else if(i < 8){
				neighbors[i] =  vec3(neighbor,restLengths.z);
			}else if(i < 12){
				if(!(neighborCoords[i].x == 0.)){
					neighbors[i] = vec3(neighbor,2.*restLengths.x);
				}else {
					neighbors[i] = vec3(neighbor,2.*restLengths.y);
				}
			}else if(i < 16){
				neighbors[i] = vec3(neighbor,2.*restLengths.z);
			}
		}
	}
	
for(int i = 0; i < 16; i ++){
	if(neighbors[i].xy != vec2(0.0,0.0)){
		t+= calculateTranslation(position, neighbors[i].xy, neighbors[i].z);
	}
}
	return t;

}


void main()	{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;

	vec2 coord = gl_FragCoord.xy;
	vec3 neighbors[16];

	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
	vec3 wind = vec3(0.);
	if(time < 10000.){{
		wind = vec3((sin(time/1000.)+1.)/100.,0.,(sin(time/1000.)-1.)/100.);
		}}
	vec3 gravityVec = vec3(0,-0.009,0.);

	vec3 velocity = (position - oldPosition) / delta;

	//fix top row so it does not move

	vec3 force = ( gravityVec + wind)*ownMass + velocity*DAMPING;
	vec3 acceleration = force/ownMass;
	vec3 t;
	vec3 newPosition = position;

	bool isPinned = false;
	for(int i = 0; i< 2; i++){
		if(uv.y == pinned[i].y/resolution.y + 1.0/(2.0*resolution.y) && uv.x == pinned[i].x/resolution.x + 1.0/(2.0*resolution.x)){
			isPinned = true;
		}
	}
	if(!isPinned){
		newPosition =  (position * 2.0 - oldPosition + acceleration * delta *delta);
		//newPosition = solveCollisions(newPosition,uv);

		t = checkConstraints(coord, newPosition);
		newPosition += t/5.5;


	}


		gl_FragColor = vec4(newPosition, 1 );
}







/*
vec3 solveCollisions(vec3 position, vec2 uv){

	float marble = restLengths.x/2.0;
	vec3 p1 = position;
	vec3 newPosition;
		for(int i = 0; i <int(resolution.x); i++){
			for(int j = 0; j <int(resolution.y); j++)
			{
				vec2 tempUV = vec2(float(i)/(resolution.x) + (1./(resolution.x*2.)) ,
				float(j)/(resolution.y) + (1./(resolution.y*2.)));
				if(uv != tempUV){
				vec3 p2 = texture2D(texturePosition, tempUV).xyz;
				vec3 dist = p1 - p2;
				float dAbs = length(dist);
				if(dAbs < 2.*marble){
					newPosition = position - normalize(dist)*(marble-dAbs);
				}}
			}
		}
		return newPosition;
}
*/
