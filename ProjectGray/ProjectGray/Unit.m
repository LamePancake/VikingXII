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