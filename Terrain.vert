#version 450 core

// Input Values
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;
layout(location = 2) in vec3 vertexNormal_modelspace;

// Output Values
out vec2 UVCoords;
out vec3 NormalWS;

void main()
{
    gl_Position = vec4(vertexPosition_modelspace, 1.0f);
    UVCoords = vertexUV;
    NormalWS = vertexNormal_modelspace;
}