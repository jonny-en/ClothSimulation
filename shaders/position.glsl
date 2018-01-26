uniform float time;
uniform float delta;

void main()	{

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 position = texture2D( texturePosition, uv ).xyz;
	vec3 velocity = texture2D( textureVelocity, uv ).xyz;
	vec3 newPos =  position + velocity * delta;
			
	gl_FragColor = vec4(newPos, 1 );
}