#version 330 core

// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;
layout(location = 2) in vec3 vertexNormal_modelspace;

// Output data ; will be interpolated for each fragment.
out vec2 UV;
out vec3 Position_worldspace;
out vec3 EyeDirection_cameraspace;
out vec3 LightDirection_cameraspace;
out vec3 Normal_cameraspace;
out vec3 Normal_worldspace;

out vec3 LightDirection_tangentspace;
out vec3 EyeDirection_tangentspace;

// Values that stay constant for the whole mesh.
uniform mat4 MVP;
uniform mat4 V;
uniform mat4 M;
uniform mat3 MV3x3;
uniform vec3 LightPosition_worldspace;

uniform sampler2D HeightMapTexture;
uniform uint width;
uniform uint height;

uniform float baseHeight;
uniform float heightDiff;

void main(){
	float xDispl = 1.0f / float(width);
	float zDispl = 1.0f / float(height);

	float heightValueF0 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(float(vertexUV.x - xDispl), float(vertexUV.y - zDispl))).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF0 = heightValue / 16777215.0f;
	}
	float heightValueF1 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x - xDispl, vertexUV.y)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF1 = heightValue / 16777215.0f;
	}
	float heightValueF2 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x - xDispl, vertexUV.y + zDispl)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF2 = heightValue / 16777215.0f;
	}
	float heightValueF3 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x, vertexUV.y - zDispl)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF3 = heightValue / 16777215.0f;
	}
	float heightValueF4 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x, vertexUV.y)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF4 = heightValue / 16777215.0f;
	}
	float heightValueF5 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x, vertexUV.y + zDispl)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF5 = heightValue / 16777215.0f;
	}
	float heightValueF6 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x + xDispl, vertexUV.y - zDispl)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF6 = heightValue / 16777215.0f;
	}
	float heightValueF7 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x + xDispl, vertexUV.y)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF7 = heightValue / 16777215.0f;
	}
	float heightValueF8 = 0.0f;
	{
		vec3 heightMapValue = texture(HeightMapTexture, vec2(vertexUV.x + xDispl, vertexUV.y + zDispl)).rgb;
		uvec3 uHeightMapValue = uvec3(0,0,0);
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
		uint heightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
		heightValueF8 = heightValue / 16777215.0f;
	}

	vec3 vertexPosition = vertexPosition_modelspace;
	vertexPosition.y = vertexPosition.y + (baseHeight + (heightValueF4 * heightDiff));

	// Output position of the vertex, in clip space : MVP * position
	gl_Position =  MVP * vec4(vertexPosition,1);
	
	// Position of the vertex, in worldspace : M * position
	Position_worldspace = (M * vec4(vertexPosition,1)).xyz;
	
	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertexPosition_cameraspace = ( V * M * vec4(vertexPosition,1)).xyz;
	EyeDirection_cameraspace = vec3(0,0,0) - vertexPosition_cameraspace;

	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	//vec3 LightPosition_cameraspace = ( V * vec4(LightPosition_worldspace,1)).xyz;
	vec3 LightPosition_cameraspace = ( V * M * vec4(LightPosition_worldspace,1)).xyz;
	LightDirection_cameraspace = -LightPosition_cameraspace + EyeDirection_cameraspace;
	
	// UV of the vertex. No special space for this one.
	UV = vertexUV;

	// Recalculate Normals
	vec2 slope06 = vec2(zDispl, (heightValueF6 - heightValueF0) * heightDiff);
	vec2 norm06 = vec2(-slope06.y, slope06.x);
	vec2 slope17 = vec2(zDispl, (heightValueF7 - heightValueF1) * heightDiff);
	vec2 norm17 = vec2(-slope17.y, slope17.x);
	vec2 slope28 = vec2(zDispl, (heightValueF8 - heightValueF2) * heightDiff);
	vec2 norm28 = vec2(-slope28.y, slope28.x);

	vec2 slope02 = vec2(zDispl, (heightValueF2 - heightValueF0) * heightDiff);
	vec2 norm02 = vec2(-slope02.y, slope02.x);
	vec2 slope35 = vec2(zDispl, (heightValueF5 - heightValueF3) * heightDiff);
	vec2 norm35 = vec2(-slope35.y, slope35.x);
	vec2 slope68 = vec2(zDispl, (heightValueF8 - heightValueF6) * heightDiff);
	vec2 norm68 = vec2(-slope68.y, slope68.x);

	vec3 normal = vec3(0,0,0);
	normal.x = (norm06 + norm17 + norm28).x;
	normal.z = (norm02 + norm35 + norm68).x;
	normal.y = (norm06 + norm17 + norm28 + norm02 + norm35 + norm68).y / 2.0f;
	normal = normalize(normal);
	
	// model to camera = ModelView
	Normal_cameraspace = MV3x3 * normal;
	Normal_worldspace = normalize(normal);
}

