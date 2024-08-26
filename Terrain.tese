#version 450 core

layout(triangles, equal_spacing, ccw) in;

// Input Values
in vec2 UVCoordinates[];
in vec3 WorldNormals[];

// Output Values
out GEOM_INPUT
{
    vec2 UVCoords;
    vec3 PositionWS;
    vec3 EyeDirectionCS;
    vec3 LightDirectionCS;
    vec3 NormalWS;
    vec3 NormalCS;
} teseOutput;

// Constant Values
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

vec2 Interpolate2D(vec2 v00, vec2 v01, vec2 v10)
{
    float patchA = gl_TessCoord.x;
    float patchB = gl_TessCoord.y;
    float patchG = gl_TessCoord.z;

    vec2 v = patchA * v00 + patchB * v01 + patchG * v10;
    return v;
}
vec3 Interpolate3D(vec3 v00, vec3 v01, vec3 v10)
{
    float patchA = gl_TessCoord.x;
    float patchB = gl_TessCoord.y;
    float patchG = gl_TessCoord.z;

    vec3 v = patchA * v00 + patchB * v01 + patchG * v10;
    return v;
}
vec4 Interpolate4D(vec4 v00, vec4 v01, vec4 v10)
{
    float patchA = gl_TessCoord.x;
    float patchB = gl_TessCoord.y;
    float patchG = gl_TessCoord.z;

    vec4 v = patchA * v00 + patchB * v01 + patchG * v10;
    return v;
}

float CalculateHeightValue(float xCoord, float yCoord)
{
    vec3 heightMapValue = texture(HeightMapTexture, vec2(xCoord, yCoord)).rgb;
    uvec3 uHeightMapValue = uvec3(0,0,0);
    {
		uHeightMapValue.x = uint(heightMapValue.x * 256.0f);
		uHeightMapValue.y = uint(heightMapValue.y * 256.0f);
		uHeightMapValue.z = uint(heightMapValue.z * 256.0f);
    }
	uint uHeightValue = (uHeightMapValue.x * uint(256 * 256)) + (uHeightMapValue.y * uint(256)) + uHeightMapValue.z;
	float heightValue = uHeightValue / 16777215.0f;

    return heightValue;
}

void main()
{
    gl_Position = Interpolate4D(gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[2].gl_Position);
    teseOutput.UVCoords = Interpolate2D(UVCoordinates[0], UVCoordinates[1], UVCoordinates[2]);
    teseOutput.NormalWS = Interpolate3D(WorldNormals[0], WorldNormals[1], WorldNormals[2]);
    
    // UV displacement of Neighbours
    float xDispl = 1.0f / float(width);
    float zDispl = 1.0f / float(height);

    // Height Value of Vertex
    float heightValueMC = CalculateHeightValue(teseOutput.UVCoords.x, teseOutput.UVCoords.y);
    // Height Values of Vertex Neighbours
    float heightValueTL = CalculateHeightValue(teseOutput.UVCoords.x - xDispl, teseOutput.UVCoords.y - zDispl);
    float heightValueTC = CalculateHeightValue(teseOutput.UVCoords.x, teseOutput.UVCoords.y - zDispl);
    float heightValueTR = CalculateHeightValue(teseOutput.UVCoords.x + xDispl, teseOutput.UVCoords.y - zDispl);
    float heightValueML = CalculateHeightValue(teseOutput.UVCoords.x - xDispl, teseOutput.UVCoords.y);
    float heightValueMR = CalculateHeightValue(teseOutput.UVCoords.x + xDispl, teseOutput.UVCoords.y);
    float heightValueBL = CalculateHeightValue(teseOutput.UVCoords.x - xDispl, teseOutput.UVCoords.y + zDispl);
    float heightValueBC = CalculateHeightValue(teseOutput.UVCoords.x, teseOutput.UVCoords.y + zDispl);
    float heightValueBR = CalculateHeightValue(teseOutput.UVCoords.x + xDispl, teseOutput.UVCoords.y + zDispl);

    // Taking Weighted Average to avoid Super Spiky Points
    float heightValueAVG =  (heightValueMC * 0.8667f) +
                            (heightValueTC + heightValueBC + heightValueML + heightValueMR) * 0.1174f +
                            (heightValueTL + heightValueBR + heightValueBL + heightValueTR) * 0.0159f;

    // Vertex Terrain Height
    vec3 vertexHeightPos = gl_Position.xyz;
    vertexHeightPos.y = vertexHeightPos.y + (baseHeight + (heightValueAVG * heightDiff));

    // Vertex Positions
    gl_Position = MVP * vec4(vertexHeightPos, 1.0f);
    teseOutput.PositionWS = (M * vec4(vertexHeightPos, 1.0f)).xyz;

    // Eye & Light Directions
    vec3 PositionCS = (V * M * vec4(vertexHeightPos, 1.0f)).xyz;
    teseOutput.EyeDirectionCS = -PositionCS;

    vec3 LightPositionCS = (V * vec4(LightPosition_worldspace, 1.0f)).xyz;
	LightPositionCS = (V * M * vec4(LightPosition_worldspace, 1.0f)).xyz;
    teseOutput.LightDirectionCS = teseOutput.EyeDirectionCS - LightPositionCS;

    // Normal Calculations
    vec2 TSlope = vec2(zDispl, heightValueTR - heightValueTL); vec2 TNorm = normalize(vec2(-TSlope.y, TSlope.x));
    vec2 MSlope = vec2(zDispl, heightValueMR - heightValueML); vec2 MNorm = normalize(vec2(-MSlope.y, MSlope.x));
    vec2 BSlope = vec2(zDispl, heightValueBR - heightValueBL); vec2 BNorm = normalize(vec2(-BSlope.y, BSlope.x));

    vec2 LSlope = vec2(xDispl, heightValueTL - heightValueBL); vec2 LNorm = normalize(vec2(-LSlope.y, LSlope.x));
    vec2 CSlope = vec2(xDispl, heightValueTC - heightValueBC); vec2 CNorm = normalize(vec2(-CSlope.y, CSlope.x));
    vec2 RSlope = vec2(xDispl, heightValueTR - heightValueBR); vec2 RNorm = normalize(vec2(-RSlope.y, RSlope.x));

    vec3 Normal = vec3(0.0f, 0.0f, 0.0f);
    {
        Normal.x = TSlope.x + MSlope.x + BSlope.x;
        Normal.y = (TSlope.y + MSlope.y + BSlope.y + LSlope.y + CSlope.y + RSlope.y) / 2.0f;
        Normal.z = LSlope.x + CSlope.x + RSlope.x;

        Normal = normalize(Normal);
    }

    // Normal Values
    teseOutput.NormalCS = MV3x3 * Normal;
    teseOutput.NormalWS = Normal;
}
