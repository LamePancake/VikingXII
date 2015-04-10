//
//  environmentmodel.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_environmentmodel_h
#define ProjectGray_environmentmodel_h

#include "EnvironmentStats.h"

// Each vertex has (x, y, z) position, (x, y, z) normal, and (u, v) texture coodinates
#define VERTEX_SIZE (sizeof(float) * 8)

extern const float *environmentModels[ENVIRONMENT_CLASSES];
extern const unsigned int environmentVertexCounts[ENVIRONMENT_CLASSES];

#endif

