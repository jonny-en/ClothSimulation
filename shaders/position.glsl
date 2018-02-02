uniform float time;
uniform float delta;
uniform float DAMPING;	// Damping coefficent

uniform float mass;
uniform float gravity;
<<<<<<< Updated upstream
uniform float KsStructur, KdStructur, KsShear, KdShear, KsBend, KdBend; //Spring coefficents

vec3 calculateTranslation(vec3 p1,vec3 p2,float restLength){
	vec3 dist = p1 - p2;
	float dAbs = length(dist);
	float s = (restLength - dAbs)/dAbs;

	vec3 t = dist * 0.5 * s;
	return t;
}

vec3 checkConstraints(vec2 uv, vec3 position){
	vec3 t = vec3(0.0);
	vec3 p2 = position;
	if(!(uv.x == 1./(2.*resolution.x))) // left border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x-(1.0/resolution.x),uv.y)).xyz;
		t += calculateTranslation(position, p2, 3.3333);
	}
	if(!(uv.x == (1.0-1./(2.*resolution.x)))) // right border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x+(1.0/resolution.x),uv.y)).xyz;
		t += calculateTranslation(position, p2, 3.3333);
	}
	if(!(uv.y == (1.0-1./(2.*resolution.y)))) // bottom border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y+(1.0/resolution.y))).xyz;
		t += calculateTranslation(position, p2, 3.3333);
	}
	if(!(uv.y == 1./(2.*resolution.y))) // bottom border of mesh
	{
		p2 = texture2D(texturePosition, vec2(uv.x,uv.y-(1.0/resolution.y))).xyz;
		t += calculateTranslation(position, p2, 3.3333);
	}
	return t;
}
=======
>>>>>>> Stashed changes


void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
<<<<<<< Updated upstream
	vec3 gravityVec = vec3(0.0009,-0.000981,-0.0009);
	vec3 velocity = (position - oldPosition) / delta;



	//fix top row so it does not move




	vec3 force = gravityVec*ownMass + velocity*DAMPING;




vec3 acceleration = force/ownMass;



	vec3 newPosition = position;
	if(!(uv.y == 1.0/(2.0*resolution.y) && (uv.x == 1.0/(2.0*resolution.x)||uv.x == (1.- 1.0/(2.0*resolution.x)))) ){
		vec3 t = checkConstraints(uv, position);
 	 position += t*0.5;
	 newPosition =  (position * 2.0 - oldPosition + acceleration * delta *delta);


	}


		gl_FragColor = vec4(newPosition,1 );
=======
	vec3 gravity = vec3(0.0,-0.0981,-0.0001);
	vec3 velocity = (position - oldPosition) / delta;
	vec3 t = vec3(0.,0.,0.);
	//fix top row so it does not move
	if((uv.y == 1.0/(2.0*resolution.y)) || (uv.y == 1.-(1.0/(2.0*resolution.y)))){
	 	ownMass = 0.0;
	}
	else{
		vec2 topUV = vec2(uv.x, uv.y - 1./(resolution.y));
		vec3 position2 = texture2D( texturePosition, topUV).xyz;
		vec3 dist = position - position2;
		float distanceAbs = distance( position, position2 );
		float s = ((3. - distanceAbs)/distanceAbs);
		t += dist * 0.5 * s;
		vec2 bottomUV = vec2(uv.x, uv.y + 1./(resolution.y));
		vec3 position3 = texture2D( texturePosition, bottomUV).xyz;
		vec3 dist2 = position - position3;
		float distanceAbs2 = distance( position, position3 );
		float s2 = ((5. - distanceAbs2)/distanceAbs2);
		t += dist2 * 0.5 * s2;
	}

	vec3 force = gravity * ownMass + velocity*DAMPING;
	vec3 acceleration = vec3(0.,0.,0.);
	if(ownMass > 0.){
	acceleration = force / ownMass;
	}
	vec3 newPosition =  (position * 2.0 - oldPosition + acceleration * delta *delta) + t/10.;
	
	gl_FragColor = vec4(newPosition,1 );
>>>>>>> Stashed changes
}
