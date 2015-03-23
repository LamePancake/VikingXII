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

attribute vec2 texCoordIn;
varying vec2 texCoordOut;

void main()
{
    texCoordOut = texCoordIn;

    
    gl_Position = translationMatrix * position;
}