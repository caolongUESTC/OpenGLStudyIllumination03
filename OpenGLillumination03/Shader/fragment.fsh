#version 300 es
precision highp float;
uniform vec3 lightPos; //光源坐标
uniform vec3 viewPos;  //视觉坐标
uniform vec3 objectColor;
uniform vec3 lightColor;


in vec3 normalCoord; //法线
in vec3 fragPos;//渲染的物体坐标
out vec4 fragColor;
void main()
{
    //环境光
    lowp float ambientStrength = 0.1;
    lowp vec3 ambient = ambientStrength * lightColor;
    
    //散射光
    lowp float diffuseStrength = 0.5;
    lowp vec3 norm = normalize(normalCoord);
    lowp vec3 lightDir = normalize(lightPos - fragPos);
    lowp float diff = max(dot(norm, lightDir), 0.0);
    lowp vec3 diffuse = diff * diffuseStrength * lightColor;
    
    //镜面光
    lowp float specularStrength = 0.5;
    lowp vec3 viewDir = normalize(viewPos - fragPos);
    lowp vec3 reflectDir = reflect(-lightDir, norm);
    lowp float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    lowp vec3 specular = specularStrength * spec * lightColor;

    lowp vec3 result = (ambient + diffuse + specular ) * objectColor;
    fragColor = vec4(result, 1.0);
    
}
