//
//  UnitStats.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

/**
 * Indicates the ship's general class.
 *
 * Light units can move quickly, but they have little health and do not have a large attack range or damage.
 * Medium units have both moderate move range and attack damage/range.
 * Heavy units can't move far, but they can deal significant damage.
 */
typedef enum _ShipClass {
    LIGHT = 0,
    MEDIUM = 1,
    HEAVY = 2
} ShipClass;

typedef struct _ShipStats {
    //stats
    int hull;
    int attRange;
    int damage;
    int moveRange;
    float accuracy;
    float critChance;
    float critModifier;
    int actionsPerTurn;
    //health
    int engineHealth;
    float weaponHealth;
    int shipHealth;
    //assets
    //None for now
} ShipStats;

extern const ShipStats shipBaseStats[];