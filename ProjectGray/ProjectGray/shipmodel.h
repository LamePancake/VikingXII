//
//  Header.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Header_h
#define ProjectGray_Header_h

#include "UnitStats.h"

// Each vertex has (x, y, z) position, (x, y, z) normal, and (u, v) texture coodinates
#define VERTEX_SIZE (sizeof(float) * 8)

extern const float *shipModels[NUM_FACTIONS][NUM_CLASSES];
extern const unsigned int shipVertexCounts[NUM_FACTIONS][NUM_CLASSES];

#endif
