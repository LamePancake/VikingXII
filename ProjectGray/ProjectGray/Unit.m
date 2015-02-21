//
//  Unit.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-15.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"


@implementation Unit

- (instancetype) initWithCoords:(GLKVector3)pos And:(GLKVector3)rot And:(float)scl
{
    self = [super init];
    
    if(self) {
        self.position = pos;
        self.rotation = rot;
        self.scale = scl;
        self.critChance = 0.05f;
        self.attRange = 3;
        self.accuracy = 0.75f;
        self.damage = 16;
        self.weaponHealth = 1;
        self.critModifier = 1.5f;
    }
    return self;
}

- (void) initShip:(int)faction And:(int)shipClass
{
    [self initFaction:faction And:shipClass];
}

- (void) initFaction:(int)fac And:(int)shipClass
{
    if(fac == VIKINGS)
    {
        [self initVikingClass:fac];
    }
    else if(fac == ALIENS)
    {
        [self initGrayClass:fac];
    }
}

- (void) initVikingClass:(int)shipClass
{
    if(shipClass == 0)
    {
        _modelData = l_vikingVerts;
        _modelArrSize = 878592;
        _numModelVerts = l_vikingNumVerts;
    }
}

- (void) initGrayClass:(int)shipClass
{
    if(shipClass == 1)
    {
        //_modelData = &chicken_triagVerts;
        //_modelArrSize = 127488;
        //_numModelVerts = chicken_triagNumVerts;
        _modelData = h_vikingVerts;
        _modelArrSize = 1453824;
        _numModelVerts = h_vikingNumVerts;
    }
}
@end