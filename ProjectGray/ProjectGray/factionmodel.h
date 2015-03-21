//
//  factionmodel.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//
// Contains all faction specific items

#ifndef ProjectGray_factionmodel_h
#define ProjectGray_factionmodel_h

#include "ItemStats.h"
#include "UnitStats.h"

// Each vertex has (x, y, z) position, (x, y, z) normal, and (u, v) texture coodinates
#define VERTEX_SIZE (sizeof(float) * 8)

extern const float *factionModels[NUM_FACTIONS][ITEM_CLASSES];
extern const unsigned int factionVertexCounts[NUM_FACTIONS][ITEM_CLASSES];

#endif
