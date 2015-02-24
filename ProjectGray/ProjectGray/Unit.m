//
//  Unit.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-15.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"

@interface Unit ()
    @property int actionsPerRound; //How much AP this unit should have each round
@end

@implementation Unit

- (instancetype) initWithPosition: (GLKVector3)pos andRotation:(GLKVector3)rot andScale:(float)scl andHex:(Hex *)hex
{
    self = [super init];
    
    if(self) {
        self.position = pos;
        self.rotation = rot;
        self.scale = scl;
        self.critChance = 0.05f;
        self.attRange = 5;
        self.accuracy = 0.75f;
        self.damage = 16;
        self.weaponHealth = 1;
        self.critModifier = 1.5f;
        self.hex = hex;
        self.moveRange = 2;
        self.actionsPerRound = 3;
        self.actionPool = _actionsPerRound;
    }
    return self;
}

- (instancetype) initWithValues:(int)shipType faction:(int)factionType position:(GLKVector3)atPos rotation:(GLKVector3)shipRot hex:(Hex *)onHex fromBaseClass:(ShipClass)baseClass model:(float*)modData modelArray:(unsigned int)modArraySize vertices:(unsigned int)numVerts{
    self = [super init];
    
    _shipClass = shipType;
    _faction = factionType;
    _position = atPos;
    _rotation = shipRot;
    _hex = onHex;
    _shipStats = shipBaseStats[baseClass];
    _modelData = modData;
    _modelArrSize = modArraySize;
    _numModelVerts = numVerts;
    return self;
}

- (instancetype) initShipWithFaction:(Faction)faction andShipClass:(ShipClass)shipClass andHex:(Hex *)startAt
{
    [self initFaction:faction And:shipClass];
    _hex = startAt;
    return self;
}

- (void) initShipWithFaction:(Faction)faction andShipClass:(ShipClass)shipClass
{
    [self initFaction:faction And:shipClass];
}

- (void) initFaction:(int)fac And:(int)shipClass
{
    _faction = fac;
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
        _modelData = h_vikingVerts;
        _modelArrSize = 1453824;
        _numModelVerts = h_vikingNumVerts;
    }
}

-(void)resetAP {
    _actionPool = _actionsPerRound;
}
@end