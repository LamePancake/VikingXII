//
//  Unit.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-15.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Unit_h
#define ProjectGray_Unit_h

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "l_vikingVertices.h"
#import "h_vikingVertices.h"
#import "Hex.h"

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
    HEAVY
} ShipClass;

/**
 *
 */
typedef enum _Faction {
    VIKINGS,
    ALIENS
} Faction;

@interface Unit : NSObject

@property (nonatomic) int shipClass;
@property (nonatomic) int faction;
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 rotation;
@property (nonatomic) Hex* hex;
@property (nonatomic) float scale;

//stats
@property (nonatomic) int hull;//HP
@property (nonatomic) int attRange;//How many hexes away can be attacked
@property (nonatomic) int damage;
@property (nonatomic) int moveRange;//How many hexes can be moved per AP
@property (nonatomic) int accuracy;//Percentage to hit
@property (nonatomic) int actionPool;//AP count for current turn
//health
@property (nonatomic) int engineHealth;
@property (nonatomic) int weaponHealth;
@property (nonatomic) int shipHealth;
//assets
@property (nonatomic) float *modelData;
@property (nonatomic) unsigned int modelArrSize;
@property (nonatomic) unsigned int numModelVerts;

- (instancetype) initWithCoords:(GLKVector3)pos And:(GLKVector3)rot And:(float)scl;
- (void) initShip:(int)faction And:(int)shipClass;
@end
#endif
