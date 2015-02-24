//
//  Shader.fsh
//  Hexy3D
//
//  Created by Dan Russell on 2015-01-31.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
