//
//  UnitStats.c
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "UnitStats.h"
const ShipStats shipBaseStats[] = {
    // Light ship base stats
    {
        10,         // Hull
        2,          // Attack range
        2,          // Damage modifier
        2,          // Movement range
        100.0f,     // Accuracy
        25.0f,      // Critical hit chance
        1.5f,       // Critical hit modifier
        3,          // Actions points per turn
        5,          // Engine health
        5.0f,       // Weapon health
        10          // Ship health
    },
    // Medium ship base stats
    {
        10,         // Hull
        2,          // Attack range
        2,          // Damage modifier
        2,          // Movement range
        100.0f,     // Accuracy
        25.0f,      // Critical hit chance
        1.5f,       // Critical hit modifier
        3,          // Action points per turn
        5,          // Engine health
        5.0f,       // Weapon health
        10,         // Ship health
    },
    // Heavy ship base stats
    {
        10,         // Hull
        2,          // Attack range
        2,          // Damage modifier
        2,          // Movement range
        100.0f,     // Accuracy
        25.0f,      // Critical hit chance
        1.5f,       // Critical hit modifier
        3,          // Actions points per turn
        5,          // Engine health
        5.0f,       // Weapon health
        10          // Ship health
    }
};