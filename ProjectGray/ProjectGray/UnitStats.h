//
//  UnitStats.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

/**
 * The faction which the ship belongs to.
 */
#define NUM_FACTIONS 2 /// The number of factions. Must be updated when factions are added/deleted.
typedef enum _Faction {
    VIKINGS = 0,
    ALIENS = 1
} Faction;

/**
 * Indicates the ship's general class.
 *
 * Light units can move quickly, but they have little health and do not have a large attack range or damage.
 * Medium units have both moderate move range and attack damage/range.
 * Heavy units can't move far, but they can deal significant damage.
 */
#define NUM_CLASSES 3 /// The number of of classes. Must be updated when factions are added/deleted.
typedef enum _ShipClass {
    LIGHT = 0,
    MEDIUM = 1,
    HEAVY = 2
} ShipClass;

typedef struct _ShipStats {
    // Ranges & action point limitations
    int attackRange;
    int actionPointsPerAttack;
    int movesPerActionPoint;
    int actionPool;
    
    // Attack modifiers
    float accuracy;
    float critChance;
    float critModifier;
    int damage;
    
    // Health
    int hull;
    int engineHealth;
    float weaponHealth;
    int shipHealth;
} ShipStats;

extern const ShipStats factionShipStats[NUM_FACTIONS][NUM_CLASSES];