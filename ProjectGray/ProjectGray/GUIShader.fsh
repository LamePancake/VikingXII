//
//  Shader.fsh
//  Hexy3D
//
//  Created by Dan Russell on 2015-01-31.
//  Copyright (c) 2015 Trevor Ware. All rights reserved.
//

varying highp vec2 texCoordOut;
uniform sampler2D texture;

void main()
{
    gl_FragColor = texture2D(texture, texCoordOut);
}