//
//  Item.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Item_h
#define ProjectGray_Item_h

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "factionmodel.h"
#import "Hex.h"
#import "ItemStats.h"
#import "GameObject.h"

extern const float ITEM_SCALE;
extern const float ITEM_HEIGHT;
extern const float PROJECTILE_SCALE;
@interface Item : NSObject <GameObject>

@property (nonatomic) int itemClass;
@property (nonatomic) int faction;
@property (nonatomic) GLKVector3 initRotation;
@property (nonatomic) Hex* hex;//Current hex that unit inhabits

//stats
//@property (readonly) ItemStats* stats;      // Gets a pointer to the ship's stats struct. Note: stats can be set using the pointer, but the pointer itself cannot be redirected.

//assets
@property (nonatomic) const float *modelData;
@property (nonatomic) unsigned int modelArrSize;
@property (nonatomic) unsigned int numModelVerts;

//Task related
//@property (nonatomic) BOOL taskAvailable;

-(instancetype) initWithFaction: (Faction)faction andClass: (ItemClasses)itemClass atPosition:(GLKVector3)atPos withRotation:(GLKVector3)itemRot andScale: (GLKVector3)scl
                          onHex:(Hex*)hex;
@end


#endif
