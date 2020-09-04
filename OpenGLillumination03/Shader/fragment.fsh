uniform lowp vec3 lightPos; //光源距离
uniform lowp vec3 objectColor;
uniform lowp vec3 lightColor;

varying lowp vec3 normalCoord;
varying lowp vec3 fragPos;
void main()
{
    //环境光
    lowp float ambientStrength = 0.1;
    lowp vec3 ambient = ambientStrength * lightColor;
    
    //散射光
    lowp vec3 norm = normalize(normalCoord);
    lowp vec3 lightDir = normalize(lightPos - fragPos);
    lowp float diff = max(dot(norm, lightDir), 0.0);
    lowp vec3 diffuse = diff * lightColor;
    
    lowp vec3 result = (ambient + diffuse) * objectColor;
    gl_FragColor = vec4(result, 1.0);
}
