//
//  UnitStats.c
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "UnitStats.h"

const char* factionNames[] =
{
    "Vikings",
    "Aliens"
};

const char* shipImages[NUM_FACTIONS][NUM_CLASSES] =
{
    //vikings
    {
        "l_viking",
        "m_viking",
        "h_viking"
    },
    //aliens
    {
        "l_gray",
        "m_gray",
        "h_gray"
    }

};

const ShipStats factionShipStats[NUM_FACTIONS][NUM_CLASSES] = {
    // VIKINGS
    {
        // Light ship base stats
        {
            3,          // Attack range
            3,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            4,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.10f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            15,         // Damage modifier
            0.7f,       // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
        // Medium ship base stats
        {
            3,          // Attack range
            3,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.10f,      // Critical hit chance
            2.0f,      // Critical hit modifier
            5,          // Damage modifier
            0.12f,         // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
        // Heavy ship base stats
        {
            1,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            2,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.20f,      // Critical hit chance
            1.25f,       // Critical hit modifier
            30,          // Damage modifier
            0.25f,         // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
    },
    // ALIENS
    {
        // Light ship base stats
        {
            3,          // Attack range
            3,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            4,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.10f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            15,         // Damage modifier
            0.7f,          // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
        // Medium ship base stats
        {
            3,          // Attack range
            3,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.10f,      // Critical hit chance
            2.0f,      // Critical hit modifier
            5,          // Damage modifier
            0.12f,         // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
        // Heavy ship base stats
        {
            1,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            2,          // Action point pool (number at the beginning of each turn)
            0.70f,      // Accuracy
            0.20f,      // Critical hit chance
            1.25f,       // Critical hit modifier
            30,          // Damage modifier
            0.25f,         // Hull
            5,          // Engine health
            1.0f,       // Weapon health
            100         // Ship health
        },
    }
};