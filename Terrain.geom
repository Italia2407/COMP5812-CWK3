#version 450 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

// Input Values
in GEOM_INPUT
{
    vec2 UVCoords;
    vec3 PositionWS;
    vec3 EyeDirectionCS;
    vec3 LightDirectionCS;
    vec3 NormalWS;
    vec3 NormalCS;
} geomInput[];

// Output Values
out vec2 UVCoords;
out vec3 PositionWS;
out vec3 EyeDirectionCS;
out vec3 LightDirectionCS;
out vec3 NormalWS;
out vec3 NormalCS;

// Constant Values
uniform mat4 MVP;
uniform mat4 V;
uniform mat4 M;
uniform mat3 MV3x3;
uniform vec3 LightPosition_worldspace;

uniform int ShouldUse;

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

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void CopyOverVertex(int index)
{
    gl_Position = gl_in[index].gl_Position;
    UVCoords = geomInput[index].UVCoords;
    PositionWS = geomInput[index].PositionWS;
    EyeDirectionCS = geomInput[index].EyeDirectionCS;
    LightDirectionCS = geomInput[index].LightDirectionCS;
    NormalWS = geomInput[index].NormalWS;
    NormalCS = geomInput[index].NormalCS;

    EmitVertex();
}

void main()
{
if (ShouldUse == 0) {
    CopyOverVertex(0);
    CopyOverVertex(1);
    CopyOverVertex(2);
    EndPrimitive();
}
else {
// Create Triangular Grass Blades
    vec4 TriPos = (gl_in[0].gl_Position + gl_in[1].gl_Position + gl_in[2].gl_Position) / 3.0f;
    vec3 TriWorldPos = (geomInput[0].PositionWS + geomInput[1].PositionWS + geomInput[2].PositionWS) / 3.0f;
    vec2 TriUV = (geomInput[0].UVCoords + geomInput[1].UVCoords + geomInput[2].UVCoords) / 3.0f;
    vec3 TriEyeDir = (geomInput[0].EyeDirectionCS + geomInput[1].EyeDirectionCS + geomInput[2].EyeDirectionCS) / 3.0f;
    vec3 TriLightDir = (geomInput[0].LightDirectionCS + geomInput[1].LightDirectionCS + geomInput[2].LightDirectionCS) / 3.0f;
    vec3 TriNormal = (geomInput[0].NormalWS + geomInput[1].NormalWS + geomInput[2].NormalWS) / 3.0f;

    // Terrain Parameters
    float uprightness = dot(TriNormal, vec3(0.0f, 1.0f, 0.0f));
	vec2 direction = normalize(vec2(NormalWS.x, NormalWS.z));

	float northness = (dot(normalize(northDirection), direction) + 1.0f) / 2.0f;
	float coastness = (dot(normalize(coastDirection), direction) + 1.0f) / 2.0f;

	float minHeight = (coldHeightS * (1-northness)) + (coldHeightN * northness);
	float maxHeight = (freezeHeightS * (1-northness)) + (freezeHeightN * northness);

	float minSlope = (gripSlopeL * (1-coastness)) + (gripSlopeC * coastness);
	float maxSlope = (stableSlopeL * (1-coastness)) + (stableSlopeC * coastness);

    // Compute How Much Snow (hence non foliage) Terrain Should Have
	float sT;
	if (TriWorldPos.y < minHeight)
		sT = 0.0f;
	else if (TriWorldPos.y > maxHeight)
		sT = 1.0f;
	else
	{
		float hDiff = maxHeight - minHeight;
		if (hDiff != 0.0f)
			sT = (TriWorldPos.y - minHeight) / hDiff;
	}

	// Compute How Much Rock (hence non foliage) Terrain Should Have
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

    float foliageAmount = (pow(1.0f - rT, 4.0f) * pow(1.0f - sT, 4.0f)) * 0.05f;
    float foliageSeed = rand(geomInput[0].UVCoords);
    
    if (foliageSeed < foliageAmount)
    {
        // Point 1
        gl_Position = TriPos + vec4(-0.05f, 0.0f, 0.0f, 0.0f);
        UVCoords = vec2(0.0f, 0.0f);
        EyeDirectionCS = TriEyeDir;
        LightDirectionCS = TriLightDir;

        PositionWS = vec3(0.0f, -1.0f, 0.0f);
        NormalWS = vec3(coastDirection.x, 0.0f, coastDirection.y);
        NormalCS = normalize(TriEyeDir);
        EmitVertex();

        // Point 2
        gl_Position = TriPos + vec4(0.05f, 0.0f, 0.0f, 0.0f);
        UVCoords = vec2(1.0f, 0.0f);
        EyeDirectionCS = TriEyeDir;
        LightDirectionCS = TriLightDir;

        PositionWS = vec3(0.0f, -1.0f, 0.0f);
        NormalWS = vec3(coastDirection.x, 0.0f, coastDirection.y);
        NormalCS = normalize(TriEyeDir);
        EmitVertex();

        // Point 3
        gl_Position = TriPos + vec4(0.03f, 0.35f * pow(1.0f - rT, 4.0f) * pow(1.0f - sT, 4.0f), 0.0f, 0.0f);
        UVCoords = vec2(1.0f, 1.0f);
        EyeDirectionCS = TriEyeDir;
        LightDirectionCS = TriLightDir;

        PositionWS = vec3(0.0f, -1.0f, 0.0f);
        NormalWS = vec3(coastDirection.x, 0.0f, coastDirection.y);
        NormalCS = normalize(TriEyeDir);
        EmitVertex();

        EndPrimitive();
    }
}
}