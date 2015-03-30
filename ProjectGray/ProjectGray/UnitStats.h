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
typedef enum _Faction {
    VIKINGS,
    ALIENS,
    NUM_FACTIONS
} Faction;

/**
 * Indicates the ship's general class.
 *
 * Light units can move quickly, but they have little health and do not have a large attack range or damage.
 * Medium units have both moderate move range and attack damage/range.
 * Heavy units can't move far, but they can deal significant damage.
 */
typedef enum _ShipClass {
    LIGHT,
    MEDIUM,
    HEAVY,
    NUM_CLASSES
} ShipClass;

typedef struct _ShipStats {
    // Ranges & action point limitations
    int attackRange;
    int healRange;
    int actionPointsPerAttack;
    int actionPointsPerHeal;
    int actionPointsPerScout;
    int movesPerActionPoint;
    int actionPool;
    
    // Attack modifiers
    float accuracy;
    float critChance;
    float critModifier;
    float damage;
    
    // Health
    float hull;
    int engineHealth;
    float weaponHealth;
    int shipHealth;
    
    // Rotation about Z to fire
    float relativeFireRotation;
} ShipStats;

extern const ShipStats factionShipStats[NUM_FACTIONS][NUM_CLASSES];
extern const char* factionNames[NUM_FACTIONS];
extern const char* shipImages[NUM_FACTIONS][NUM_CLASSES];