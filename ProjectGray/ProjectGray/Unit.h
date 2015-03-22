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
#import "shipmodel.h"
#import "l_vikingVertices.h"
#import "h_vikingVertices.h"
#import "Hex.h"
#import "UnitStats.h"
#import "GameObject.h"

@interface Unit : NSObject <GameObject>

@property (nonatomic) int shipClass;
@property (nonatomic) int faction;
//@property (nonatomic) GLKVector3 position;
//@property (nonatomic) GLKVector3 rotation;
@property (nonatomic) GLKVector3 initRotation;
@property (nonatomic) Hex* hex;//Current hex that unit inhabits
//@property (nonatomic) float scale;

//stats
@property (readonly) ShipStats* stats;      // Gets a pointer to the ship's stats struct. Note: stats can be set using the pointer, but the pointer itself cannot be redirected.

//assets
@property (nonatomic) const float *modelData;
@property (nonatomic) unsigned int modelArrSize;
@property (nonatomic) unsigned int numModelVerts;
@property (nonatomic) bool active;

//Task related
//@property (nonatomic) BOOL taskAvailable;

-(instancetype) initWithFaction: (Faction)faction andClass: (ShipClass)shipClass atPosition:(GLKVector3)atPos withRotation:(GLKVector3)shipRot andScale: (float)scl onHex:(Hex*)hex;
-(void) resetAP;
-(BOOL) ableToAttack;
-(int) moveRange;
@end
#endif
