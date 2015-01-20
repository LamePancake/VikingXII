//
//  Shader.fsh
//  ProjectGrey
//
//  Created by Dan Russell on 2015-01-20.
//  Copyright (c) 2015 lamepancake. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
