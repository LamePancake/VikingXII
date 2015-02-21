//
//  Shader.fsh
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

varying lowp vec4 colorVarying;
uniform sampler2D texture;
varying highp vec2 texCoordOut;

void main()
{
    //gl_FragColor = colorVarying;
    gl_FragColor = texture2D(texture, texCoordOut);
}
