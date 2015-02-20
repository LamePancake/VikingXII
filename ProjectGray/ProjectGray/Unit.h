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
#import "chicken_triag.h"
#import "l_vikingVertices.h"

@interface Unit : NSObject

@property (nonatomic) int shipClass; //0 for light 1 for medium 2 for heavy 3 for convoy
@property (nonatomic) int faction; //0 for vikings 1 for aliens
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 rotation;
@property (nonatomic) float scale;
//stats
@property (nonatomic) int hull;
@property (nonatomic) int attRange;
@property (nonatomic) int damage;
@property (nonatomic) int moveRange;
@property (nonatomic) int accuracy;
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
