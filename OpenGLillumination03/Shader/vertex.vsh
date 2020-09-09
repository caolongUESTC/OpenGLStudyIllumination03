#version 300 es
precision highp float;
layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;

uniform mat4 model;
uniform mat4 modelInvertTranspose;
uniform mat4 view;
uniform mat4 projection;

out vec3 normalCoord; //法线坐标
out vec3 fragPos; //物体位置。
void main()
{
    vec4 vPos = vec4(position,1.0);
    gl_Position =  projection * view * model * vPos;
    
    normalCoord = mat3(modelInvertTranspose) * normal; //法线向量需要进行调整。
    fragPos = vec3(model * vPos);
    
}
