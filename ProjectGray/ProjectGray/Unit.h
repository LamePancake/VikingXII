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
#import "UnitStats.h"

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
@property (nonatomic) Hex* hex;//Current hex that unit inhabits
@property (nonatomic) float scale;
//stats
@property ShipStats shipStats;
@property (nonatomic) int hull;//HP
@property (nonatomic) int attRange;//How many hexes away can be attacked
@property (nonatomic) int damage;//How much damage the ships weapon3s can deal
@property (nonatomic) int moveRange;//How many hexes can be moved per AP
@property (nonatomic) float accuracy;//Percentage to hit
@property (nonatomic) float critChance;//Percentage to get a critical
@property (nonatomic) float critModifier;//a multiplier that get applied to damage if a crit happens
@property (nonatomic) int actionPool;//AP count for current turn
//health
@property (nonatomic) int engineHealth;
@property (nonatomic) float weaponHealth;
@property (nonatomic) int shipHealth;
//assets
@property (nonatomic) float *modelData;
@property (nonatomic) unsigned int modelArrSize;
@property (nonatomic) unsigned int numModelVerts;
@property (nonatomic) bool active;

-(instancetype) initWithValues:(int)shipType faction:(int)factionType position:(GLKVector3)atPos rotation:(GLKVector3)shipRot hex:(Hex*)onHex fromBaseClass:(ShipClass)baseClass model:(float*)modData modelArray:(unsigned int)modArraySize vertices:(unsigned int)numVerts;

- (instancetype) initWithPosition:(GLKVector3)pos andRotation:(GLKVector3)rot andScale:(float)scl andHex: (Hex *)hex;
- (instancetype) initShipWithFaction:(Faction)faction andShipClass:(ShipClass)shipClass andHex:(Hex*)startAt;
- (void) initShipWithFaction:(Faction)faction andShipClass:(ShipClass)shipClass;
- (void) resetAP;
@end
#endif
