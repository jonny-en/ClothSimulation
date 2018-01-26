uniform float time;
uniform float delta; // about 0.016
			
void main(){	
		
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 velocity = texture2D( textureVelocity, uv ).xyz;
	velocity -= vec3(0.,.00003,0.);				
	gl_FragColor = vec4(velocity,1);
	}