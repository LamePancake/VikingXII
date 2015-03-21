//
//  factionmodel.c
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "factionmodel.h"

const float cannonBallShot[] = {
#include "cannonball.txt"
};

const float vikingFlag[] = {
#include "flag.txt"
};



const float laserShot[] = {
#include "laser.txt"
};

const float grayFlag[] = {
#include "flag.txt"
};



const float *factionModels[NUM_FACTIONS][ITEM_CLASSES] = {
    // Viking data
    {
        &(cannonBallShot[0]),
        &(vikingFlag[0]) // Currently, viking light is also the model for medium
    },
    // Alien data; for now, uses the viking data since we have no other stuff
    {
        &(laserShot[0]),
        &(grayFlag[0])
    }
};

const unsigned int factionVertexCounts[NUM_FACTIONS][ITEM_CLASSES] = {
    // Viking data
    {
        sizeof(cannonBallShot) / VERTEX_SIZE,
        sizeof(vikingFlag) / VERTEX_SIZE
    },
    // Alien data
    {
        sizeof(laserShot) / VERTEX_SIZE,
        sizeof(grayFlag) / VERTEX_SIZE
    }
};