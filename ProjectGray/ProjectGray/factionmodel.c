//
//  factionmodel.c
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "factionmodel.h"

const float lCannonBall[] = {
#include "l_cannonball.txt"
};

const float mCannonBall[] = {
#include "m_cannonball.txt"
};

const float hCannonBall[] = {
#include "h_cannonball.txt"
};

const float vikingFlag[] = {
#include "flag.txt"
};



const float lLaser[] = {
#include "l_laser.txt"
};


const float mLaser[] = {
#include "m_laser.txt"
};

const float hLaser[] = {
#include "h_laser.txt"
};

const float grayFlag[] = {
#include "flag.txt"
};



const float *factionModels[NUM_FACTIONS][ITEM_CLASSES] = {
    // Viking data
    {
        &(lCannonBall[0]),
        &(mCannonBall[0]),
        &(hCannonBall[0]),
        &(vikingFlag[0]) // Currently, viking light is also the model for medium
    },
    // Alien data; for now, uses the viking data since we have no other stuff
    {
        &(lLaser[0]),
        &(mLaser[0]),
        &(hLaser[0]),
        &(grayFlag[0])
    }
};

const unsigned int factionVertexCounts[NUM_FACTIONS][ITEM_CLASSES] = {
    // Viking data
    {
        sizeof(lCannonBall) / VERTEX_SIZE,
        sizeof(mCannonBall) / VERTEX_SIZE,
        sizeof(hCannonBall) / VERTEX_SIZE,
        sizeof(vikingFlag) / VERTEX_SIZE
    },
    // Alien data
    {
        sizeof(lLaser) / VERTEX_SIZE,
        sizeof(mLaser) / VERTEX_SIZE,
        sizeof(hLaser) / VERTEX_SIZE,
        sizeof(grayFlag) / VERTEX_SIZE
    }
};