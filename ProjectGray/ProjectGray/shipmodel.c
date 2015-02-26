//
//  shipmodel.c
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "shipmodel.h"

const float vikingLight[] = {
    #include "vikingVertsLight.txt"
};

const float vikingHeavy[] = {
    #include "vikingVertsHeavy.txt"
};

const float *shipModels[NUM_FACTIONS][NUM_CLASSES] = {
    // Viking data
    {
        &(vikingLight[0]),
        &(vikingLight[0]), // Currently, viking light is also the model for medium
        &(vikingHeavy[0])
    },
    // Alien data; for now, uses the viking data since we have no other stuff
    {
        &(vikingHeavy[0]),
        &(vikingLight[0]),
        &(vikingHeavy[0])
    }
};

const unsigned int shipVertexCounts[NUM_FACTIONS][NUM_CLASSES] = {
    // Viking data
    {
        sizeof(vikingLight) / VERTEX_SIZE,
        sizeof(vikingLight) / VERTEX_SIZE,
        sizeof(vikingHeavy) / VERTEX_SIZE
    },
    // Alien data
    {
        sizeof(vikingHeavy) / VERTEX_SIZE,
        sizeof(vikingLight) / VERTEX_SIZE,
        sizeof(vikingHeavy) / VERTEX_SIZE
    }
};