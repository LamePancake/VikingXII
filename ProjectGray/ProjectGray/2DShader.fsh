//
//  Shader.fsh
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//
precision mediump float;
varying lowp vec4 colorVarying;
uniform sampler2D texture;
uniform vec4 tint;
varying highp vec2 texCoordOut;

void main()
{
    
    //gl_FragColor = colorVarying * texture2D(texture, texCoordOut);
    
    gl_FragColor = texture2D(texture, texCoordOut) * tint;
}