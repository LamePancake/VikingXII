//
//  Shader.fsh
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//
precision highp float;
varying highp vec4 colorVarying;
uniform sampler2D texture;
varying highp vec2 texCoordOut;
uniform vec3 lightPos;
uniform mat3 normalMatrix;
varying highp vec3 norm;
varying highp vec4 pos;

void main()
{
    vec3 viewNormal = normalize(normalMatrix * norm);
    float nDotVP = max(0.0, dot(viewNormal, normalize(lightPos)));
    
    //test
    vec3 E = normalize(-pos.xyz);
    vec3 L = normalize(lightPos + pos.xyz);
    vec3 H = normalize(L+E);
    float Ks = pow(max(dot(viewNormal, H), 0.0), 20.0);
    vec4 specular;
    
    vec4 specularComponent = vec4(3.0, 3.0, 3.0, 3.0);
    specular = clamp(Ks*specularComponent, 0.0, 1.0);
    vec4 finalColor = colorVarying + (specular * nDotVP);
    
    gl_FragColor = finalColor * texture2D(texture, texCoordOut);
    //gl_FragColor = texture2D(texture, texCoordOut);
}

