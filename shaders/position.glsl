uniform float time;
uniform float delta;
uniform float DAMPING;	// Damping coefficent

uniform float mass;
uniform float gravity;
uniform vec3 restLenghts; //Spring coefficents

vec3 calculateTranslation(vec3 p1,vec3 p2,float restLength){
	vec3 dist = p1 - p2;
	float dAbs = distance(p1,p2);
	float s = 0.;
	if(dAbs != 0.){
	s = (restLength - dAbs)/dAbs;
	}

	vec3 t = dist * 0.5  * s;


	return t;
}

vec3 solveCollisions(vec3 position, vec2 uv){

	float marble = restLenghts.x/2.0;
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

vec3 checkConstraints(vec2 uv, vec3 position){
	vec3 t = vec3(0.0);
	vec3 p2 = position;
	float restLengthX = restLenghts.x;
	float restLengthY = restLenghts.y;
	float restLengthDiag = restLenghts.z;
	float stepSizeX = 1./resolution.x;
	float stepSizeY = 1./resolution.y;

//Structural constraints
	if(!(uv.x == 1./2.* stepSizeX)) // left border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x-stepSizeX,uv.y)).xyz;
		t += (calculateTranslation(position, p2,restLengthX));
		//shearing constraints
		if(!(uv.y == 1./2.*stepSizeY)){
			p2 = texture2D(texturePosition, vec2(uv.x - stepSizeX, uv.y - stepSizeY)).xyz;
			t += calculateTranslation(position, p2, restLengthDiag);
		}
		if(!(uv.y == (1.-1./2.*stepSizeY))){
			p2 = texture2D(texturePosition, vec2(uv.x - stepSizeX, uv.y + stepSizeY)).xyz;
			t += calculateTranslation(position, p2, restLengthDiag);
		}
		// Bending checkConstraints
		if(!(uv.x <= stepSizeX + (1./2.*stepSizeX))){
			p2 = texture2D(texturePosition, vec2(uv.x - 2.*stepSizeX,uv.y)).xyz;
			t += calculateTranslation(position, p2, 2.*restLengthX);

			if(!(uv.y <= stepSizeY + (1./2.*stepSizeY))){
				p2 = texture2D(texturePosition, vec2(uv.x - 2.*stepSizeX, uv.y - 2.*stepSizeY)).xyz;
				t += calculateTranslation(position, p2, 2.*restLengthDiag);
			}
			if(!(uv.y>= 1.0 - stepSizeY - (1./2.*stepSizeY))){
				p2 = texture2D(texturePosition, vec2(uv.x - 2.*stepSizeX, uv.y + 2.*stepSizeY)).xyz;
				t += calculateTranslation(position, p2, 2.*restLengthDiag);
				}
			}
	}
	if(!(uv.x == (1.-1./2.*stepSizeX))) // right border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x+stepSizeX,uv.y)).xyz;
		t += calculateTranslation(position, p2, restLengthX);
		//shearing constraints

		if(!(uv.y == 1./2.*stepSizeY)){
			p2 = texture2D(texturePosition, vec2(uv.x + stepSizeX, uv.y - stepSizeY)).xyz;
			t += calculateTranslation(position, p2, restLengthDiag);
		}
		 if(!(uv.y == (1.-1./2.*stepSizeY))){
			p2 = texture2D(texturePosition, vec2(uv.x + stepSizeX, uv.y + stepSizeY)).xyz;
			t += calculateTranslation(position, p2, restLengthDiag);
		}

		if(!(uv.x >= 1.0 - stepSizeX - (1./2.*stepSizeX))){
			p2 = texture2D(texturePosition, vec2(uv.x + 2.*stepSizeX,uv.y)).xyz;
			t += calculateTranslation(position, p2, 2.*restLengthX);
			if(!(uv.y <= stepSizeY + (1./2.*stepSizeY))){
				p2 = texture2D(texturePosition, vec2(uv.x + 2.*stepSizeX, uv.y - 2.*stepSizeY)).xyz;
				t += calculateTranslation(position, p2, 2.*restLengthDiag);
			}
			 if(!(uv.y>= 1.0 - stepSizeY - (1./2.*stepSizeY))){
				p2 = texture2D(texturePosition, vec2(uv.x + 2.*stepSizeX, uv.y + 2.*stepSizeY)).xyz;
				t += calculateTranslation(position, p2, 2.*restLengthDiag);
			}

		}

	}
	if(!(uv.y == (1.0-1./2.*stepSizeY))) // bottom border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y+stepSizeY)).xyz;
		t += calculateTranslation(position, p2, restLengthY);
	}
	if(!(uv.y == 1./2.*stepSizeY)) // top border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y-stepSizeY)).xyz;
		t += calculateTranslation(position, p2, restLengthY);
	}

	if(!(uv.y <= stepSizeY + (1./2.*stepSizeY))){
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y - 2.*stepSizeY)).xyz;
		t += calculateTranslation(position, p2, 2.*restLengthY);
	}
	if(!(uv.y >= 1.0 - stepSizeY - (1./2.*stepSizeY))){
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y + 2.*stepSizeY)).xyz;
		t += calculateTranslation(position, p2, 2.*restLengthY);
	}

	return t;

}


void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
	vec3 gravityVec = vec3((sin(time/1000.)+1.)/100.,-0.09,(sin(time/1000.)-1.)/100.);
	vec3 velocity = (position - oldPosition) / delta;

	//fix top row so it does not move

	vec3 force = gravityVec*ownMass + velocity*DAMPING;
	vec3 acceleration = force/ownMass;
	vec3 t;
	vec3 newPosition = position;
	
	if(!(uv.y == 1.0/(2.0*resolution.y) && (uv.x == 1.0/(2.0*resolution.x)||uv.x == (1.- 1.0/(2.0*resolution.x)))) ){
		newPosition =  (position * 2.0 - oldPosition + acceleration * delta *delta);
		//newPosition = solveCollisions(newPosition,uv);

		t = checkConstraints(uv, newPosition);
		newPosition += t/12.;


	}


		gl_FragColor = vec4(newPosition, 1 );
}
