#version 300 es
precision highp float;
struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct Light {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

in vec3 normalCoord; //法线
in vec3 fragPos;//渲染的物体坐标

uniform vec3 viewPos;  //视觉坐标
uniform Material material;
uniform Light light;

out vec4 fragColor; //输出颜色

void main()
{
    //环境光
    vec3 ambient = light.ambient * material.ambient;
    
    //散射光
    vec3 norm = normalize(normalCoord);
    vec3 lightDir = normalize(light.position - fragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * (diff * material.diffuse);
    
    //镜面光
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * (spec * material.specular);

    vec3 result = ambient + diffuse + specular;
    fragColor = vec4(result, 1.0);
}
