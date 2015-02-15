//
//  Shader.vsh
//  Hexy3D
//
//  Created by Dan Russell on 2015-01-31.
//  Copyright (c) 2015 Trevor Ware. All rights reserved.
//

attribute vec2 position;
uniform vec4 color;

varying lowp vec4 colorVarying;

void main()
{
    colorVarying = color;
    gl_Position = vec4(position,0.0,1.0);
}