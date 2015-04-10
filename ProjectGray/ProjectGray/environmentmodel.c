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

const float asteroidVar1[] =
{
#include "asteroidcluster1.txt"
};

const float asteroidVar2[] =
{
#include "asteroidcluster2.txt"
};

const float *environmentModels[ENVIRONMENT_CLASSES] = {
    &(asteroid[0]),
    &(asteroidVar1[0]),
    &(asteroidVar2[0])
};

const unsigned int environmentVertexCounts[ENVIRONMENT_CLASSES] = {
    sizeof(asteroid) / VERTEX_SIZE,
    sizeof(asteroidVar1) / VERTEX_SIZE,
    sizeof(asteroidVar2) / VERTEX_SIZE,
};