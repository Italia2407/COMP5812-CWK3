#version 450 core

// Interpolated values from the vertex shaders
in vec2 UVCoords;
in vec3 PositionWS;
in vec3 EyeDirectionCS;
in vec3 LightDirectionCS;
in vec3 NormalCS;
in vec3 NormalWS;

// Ouput data
out vec3 color;

// Values that stay constant for the whole mesh.
uniform mat4 V;
uniform mat4 M;
uniform mat3 MV3x3;
uniform vec3 LightPosition_worldspace;

// Mountain Texture Parameters
uniform sampler2D RockTextureSampler;
uniform sampler2D GrassTextureSampler;
uniform sampler2D SnowTextureSampler;

uniform sampler2D RockSTextureSampler;
uniform sampler2D GrassSTextureSampler;
uniform sampler2D SnowSTextureSampler;

uniform vec2 northDirection;
uniform vec2 coastDirection;

uniform float coldHeightN;
uniform float coldHeightS;
uniform float freezeHeightN;
uniform float freezeHeightS;

uniform float gripSlopeC;
uniform float gripSlopeL;
uniform float stableSlopeC;
uniform float stableSlopeL;

void main(){
	vec3 normal = normalize(NormalWS);
	float uprightness = dot(NormalWS, vec3(0.0f, 1.0f, 0.0f));

	// Some properties
	// should put them as uniforms
	vec3 LightColor = vec3(1.0, 1.0, 1.0);
	float LightPower = 1.0;
	float shininess = 1;

	// Material properties
	vec3 RockDiffuseColour = texture(RockTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;
	vec3 GrassDiffuseColour = texture(GrassTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;
	vec3 SnowDiffuseColour = texture(SnowTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;

	vec3 RockSpecularColour = texture(RockSTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;
	vec3 GrassSpecularColour = texture(GrassSTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;
	vec3 SnowSpecularColour = texture(SnowSTextureSampler,vec2(UVCoords.x,UVCoords.y)*64).rgb;

	// Mountain Parameters
	vec2 direction = normalize(vec2(NormalWS.x, NormalWS.z));

	float northness = (dot(normalize(northDirection), direction) + 1.0f) / 2.0f;
	float coastness = (dot(normalize(coastDirection), direction) + 1.0f) / 2.0f;

	float minHeight = (coldHeightS * (1-northness)) + (coldHeightN * northness);
	float maxHeight = (freezeHeightS * (1-northness)) + (freezeHeightN * northness);

	float minSlope = (gripSlopeL * (1-coastness)) + (gripSlopeC * coastness);
	float maxSlope = (stableSlopeL * (1-coastness)) + (stableSlopeC * coastness);

	// Compute How Much Snow Terrain Should Have
	float sT;
	if (PositionWS.y < minHeight)
		sT = 0.0f;
	else if (PositionWS.y > maxHeight)
		sT = 1.0f;
	else
	{
		float hDiff = maxHeight - minHeight;
		if (hDiff != 0.0f)
			sT = (PositionWS.y - minHeight) / hDiff;
	}

	// Compute How Much Rock Terrain Should Have
	float rT;
	if (uprightness < minSlope)
		rT = 0.0f;
	else if (uprightness > maxSlope)
		rT = 1.0f;
	else
	{
		float sDiff = maxSlope - minSlope;
		if (sDiff != 0.0f)
		{
			rT = (uprightness - minSlope) / sDiff;
		}
	}

	vec3 MaterialDiffuseColor = (((RockDiffuseColour * (rT)) + (GrassDiffuseColour * (1-rT))) * (1-sT)) + (SnowDiffuseColour * sT);
	vec3 MaterialAmbientColor = vec3(0.1,0.1,0.1) * MaterialDiffuseColor;
	vec3 MaterialSpecularColor = (((RockSpecularColour * (rT)) + (GrassSpecularColour * (1-rT))) * (1-sT)) + (SnowSpecularColour * sT);

	// Foliage has world pos below 0
	if (PositionWS.y < 0.0f)
	{
		MaterialDiffuseColor = vec3(0.15f, 0.4f, 0.15f);
		MaterialAmbientColor = vec3(0.1,0.1,0.1) * MaterialDiffuseColor;
		MaterialSpecularColor = vec3(0.0f, 0.0f, 0.0f);
	}

	// Distance to the light
	//float distance = length( LightPosition_worldspace - PositionWS );

	// Normal of the computed fragment, in camera space
	vec3 n = NormalCS;
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(LightDirectionCS);
	vec3 e = normalize(EyeDirectionCS);

	//Diffuse
	float cosTheta = clamp( dot( n,l ), 0,1 );
	vec3 diffuse = MaterialDiffuseColor * LightColor * LightPower * cosTheta ;// (distance*distance) ;
	
	//Specular
	// Eye vector (towards the camera)
	vec3 E = normalize(EyeDirectionCS);
	// Direction in which the triangle reflects the light
	vec3 B = normalize(l + e);

	float cosB = clamp(dot(n,B),0,1);
	cosB = clamp(pow(cosB,shininess),0,1);
	cosB = cosB * cosTheta * (shininess+2)/(2*radians(180.0f));
	vec3 specular = MaterialSpecularColor *LightPower*cosB;//(distance*distance);
	
	color = 
		// Ambient : simulates indirect lighting
		MaterialAmbientColor +
		// Diffuse : "color" of the object
		diffuse +
		specular;
		// Specular : reflective highlight, like a mirror
}