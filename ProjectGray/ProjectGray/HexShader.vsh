//
//  Shader.vsh
//  Hexy3D
//
//  Created by Dan Russell on 2015-01-31.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

attribute vec2 position;
uniform vec4 color;
//attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
//uniform mat3 normalMatrix;

void main()
{
    //vec3 eyeNormal = normalize(normalMatrix * normal);
    //vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    //vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    //float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    colorVarying = color;
    gl_Position = modelViewProjectionMatrix * vec4(position,0.0,1.0);
}
