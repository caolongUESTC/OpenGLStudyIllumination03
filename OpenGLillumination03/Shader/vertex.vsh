attribute vec3 position;
attribute vec3 normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec3 normalCoord;
varying lowp vec3 fragPos; //物体位置。
void main()
{
    vec4 vPos = vec4(position,1.0);
    vPos =  projection * view * model * vPos;
    
    normalCoord = normal;
    fragPos = vec3(model * vec4(position, 1.0));
    //图像翻转
    gl_Position = vPos;
    
}
