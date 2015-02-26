//
//  Unit.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-15.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"

@interface Unit ()
{
    ShipStats _shipStats;
}

    @property int actionsPerRound; //How much AP this unit should have each round
@end

@implementation Unit

<<<<<<< .mine
-(instancetype) initWithFaction: (Faction)faction andClass: (ShipClass)shipClass atPosition:(GLKVector3)atPos withRotation:(GLKVector3)shipRot andScale: (float)scl onHex:(Hex*)hex {
    if((self = [super init])) {
        _position = atPos;
        _rotation = shipRot;
        _scale = scl;
        _shipClass = shipClass;
        _faction = faction;
        _position = atPos;
        _rotation = shipRot;
        _hex = hex;
        _shipStats = factionShipStats[faction][shipClass];
        _modelData = shipModels[faction][shipClass];
        _modelArrSize = shipVertexCounts[faction][shipClass] * VERTEX_SIZE;
        _numModelVerts = shipVertexCounts[faction][shipClass];
        _active = true;
=======
- (instancetype) initWithPosition: (GLKVector3)pos andRotation:(GLKVector3)rot andScale:(float)scl andHex:(Hex *)hex
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
        self.shipHealth = 40;
        self.critModifier = 1.5f;
        self.hex = hex;
        self.movesPerActionPoint = 1;
        self.attAPRequirement = 2;
        self.actionsPerRound = 3;
        self.actionPool = _actionsPerRound;
        self.active = true;
>>>>>>> .r200
    }
    return self;
}

-(ShipStats *) stats {
    return &_shipStats;
}

-(void)resetAP {
    _shipStats.actionPool = factionShipStats[_faction][_shipClass].actionPool;
}
- (BOOL) ableToAttack
{
    return (_shipStats.actionPointsPerAttack <= _shipStats.actionPool);
}

-(int) moveRange
{
    return (_shipStats.actionPool / _shipStats.movesPerActionPoint);
}
@end