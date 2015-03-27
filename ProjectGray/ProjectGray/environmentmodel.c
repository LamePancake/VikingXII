//
//  environmentmodel.c
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "environmentmodel.h"

const float asteroid[] = {
#include "asteroid.txt"
};

const float *environmentModels[NUM_ENVIRONMENT] = {
    &(asteroid[0]),
};

const unsigned int environmentVertexCounts[NUM_ENVIRONMENT] = {
    sizeof(asteroid) / VERTEX_SIZE,
};