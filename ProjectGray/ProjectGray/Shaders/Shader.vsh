//
//  Shader.vsh
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform mat4 projectimMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 translationMatrix;
uniform vec3 lightPos;

attribute vec2 texCoordIn;
varying vec2 texCoordOut;

void main()
{
    texCoordOut = texCoordIn;
    
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = lightPos;
    vec4 diffuseColor = vec4(1.0, 1.0, 0.5, 1.0);
    vec4 ambient = vec4(0.15, 0.15, 0.2, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = (diffuseColor * nDotVP) + ambient;
    
    gl_Position = translationMatrix * position;
}