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
    }
    return self;
}

- (void) initShip:(int)faction And:(int)shipClass
{
    [self initFaction:faction And:shipClass];
}

- (void) initFaction:(int)fac And:(int)shipClass
{
    if(fac == 0)
    {
        [self initVikingClass:fac];
    }
    else if(fac == 1)
    {
        [self initGrayClass:fac];
    }
}

- (void) initVikingClass:(int)shipClass
{
    if(shipClass == 0)
    {
        //_modelData = &chicken_triagVerts;
        //_modelArrSize = 127488;
        //_numModelVerts = chicken_triagNumVerts;
        _modelData = &l_vikingVerts;
        _modelArrSize = 881568;
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
        _modelData = &chicken_triagVerts;
        _modelArrSize = 127488;
        _numModelVerts = chicken_triagNumVerts;
    }
}
@end