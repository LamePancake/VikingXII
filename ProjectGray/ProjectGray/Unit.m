//
//  Unit.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-15.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"
#import "PowerUp.h"

const float UNIT_SCALE = 0.002f;
const float UNIT_HEIGHT = 0.04f;

@interface Unit ()
{
    ShipStats _shipStats;
}

    @property int actionsPerRound; //How much AP this unit should have each round
@end

@implementation Unit

static int roundsBeforeRespawn = 1;

@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize scale = _scale;
@synthesize active = _active;
@synthesize taskAvailable = _taskAvailable;

-(instancetype) initWithFaction: (Faction)faction andClass: (ShipClass)shipClass atPosition:(GLKVector3)atPos withRotation:(GLKVector3)shipRot andScale: (GLKVector3)scl
                          onHex:(Hex*)hex {
    if((self = [super init])) {
        _position = atPos;
        _rotation = shipRot;
        _scale = scl;
        _shipClass = shipClass;
        _faction = faction;
        _position = atPos;
        _hex = hex;
        _initRotation = (faction == VIKINGS ? GLKVector3Make(0, 0, -(M_PI / 2)) : GLKVector3Make(0, 0, (M_PI / 2)));
        _rotation = GLKVector3Subtract(_initRotation, shipRot);
        _shipStats = factionShipStats[faction][shipClass];
        _modelData = shipModels[faction][shipClass];
        _modelArrSize = shipVertexCounts[faction][shipClass] * VERTEX_SIZE;
        _numModelVerts = shipVertexCounts[faction][shipClass];
        _active = true;
        _taskAvailable = true;
        _powerUp = NOPOWERUP;
        _projectiles = [[NSMutableArray alloc] init];
        _roundsToRespawn = roundsBeforeRespawn;
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

- (BOOL) ableToHeal
{
    return (_shipStats.actionPointsPerHeal <= _shipStats.actionPool);
}

- (BOOL) ableToScout
{
    return (_shipStats.actionPointsPerScout <= _shipStats.actionPool);
}

-(int) moveRange
{
    return (_shipStats.actionPool / _shipStats.movesPerActionPoint);
}

+(int) getRoundsBeforeRespawn
{
    return roundsBeforeRespawn;
}

@end