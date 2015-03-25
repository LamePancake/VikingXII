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
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
        // Medium ship base stats
        {
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
        // Heavy ship base stats
        {
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
    },
    // ALIENS
    {
        // Light ship base stats
        {
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
        // Medium ship base stats
        {
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
        // Heavy ship base stats
        {
            2,          // Attack range
            2,          // Heal range
            2,          // Action points per attack
            2,          // Action points per heal
            1,          // Moves (tiles) per action point
            3,          // Action point pool (number at the beginning of each turn)
            0.75f,      // Accuracy
            0.05f,      // Critical hit chance
            1.5f,       // Critical hit modifier
            2,          // Damage modifier
            10,         // Hull
            5,          // Engine health
            5.0f,       // Weapon health
            100         // Ship health
        },
    }
};