#version 450 core

layout (vertices = 3) out;

// Input Values
in vec2 UVCoords[];
in vec3 NormalWS[];

out vec2 UVCoordinates[];
out vec3 WorldNormals[];

uniform uint patchSubdivisions;

void main()
{
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    UVCoordinates[gl_InvocationID] = UVCoords[gl_InvocationID];
    WorldNormals[gl_InvocationID] = NormalWS[gl_InvocationID];

    if (gl_InvocationID == 0)
    {
        gl_TessLevelOuter[0] = patchSubdivisions;
        gl_TessLevelOuter[1] = patchSubdivisions;
        gl_TessLevelOuter[2] = patchSubdivisions;

        gl_TessLevelInner[0] = patchSubdivisions;
    }
}