void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	float ownMass = mass;

	vec2 coord = gl_FragCoord.xy;

	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 oldPosition = texture2D( textureOldPosition, uv ).xyz;
	vec3 wind = vec3(0.);
	if(time < 10000.){{
		wind = vec3((sin(time/1000.)+1.)/100.,0.,(sin(time/1000.)-1.)/100.);
		}}
	vec3 gravityVec = vec3(0,-0.009,0.);

	vec3 velocity = (position - oldPosition) / delta;

	//fix top row so it does not move

	vec3 force = (gravityVec + wind)*ownMass + velocity*DAMPING;
	vec3 acceleration = force/ownMass;
	vec3 t;
	
	bool isPinned = false;
	for(int i = 0; i< 2; i++){
		if(uv.y == pinned[i].y/resolution.y + 1.0/(2.0*resolution.y) && uv.x == pinned[i].x/resolution.x + 1.0/(2.0*resolution.x)){
			isPinned = true;
		}
	}
	if(!isPinned){
		position =  (position * 2.0 - oldPosition + acceleration * delta *delta);
		//newPosition = solveCollisions(newPosition,uv);
	}


		gl_FragColor = vec4(position, 1 );
}
