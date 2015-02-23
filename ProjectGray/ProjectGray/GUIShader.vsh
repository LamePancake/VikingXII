//
//  Shader.vsh
//  Hexy3D
//
//  Created by Dan Russell on 2015-01-31.
//  Copyright (c) 2015 Trevor Ware. All rights reserved.
//

attribute vec2 position;

varying lowp vec4 colorVarying;
attribute vec2 texCoordIn;
varying vec2 texCoordOut;
uniform mat4 modelViewProjectionMatrix;

void main()
{
    texCoordOut = texCoordIn;
    gl_Position = modelViewProjectionMatrix * vec4(position, -1, 1);
}