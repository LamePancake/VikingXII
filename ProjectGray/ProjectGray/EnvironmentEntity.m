//
//  EnvironmentEntity.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnvironmentEntity.h"
#import "PowerUp.h"

@interface EnvironmentEntity ()
{
}

@property int actionsPerRound; //How much AP this unit should have each round
@end

@implementation EnvironmentEntity

@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize scale = _scale;
@synthesize active = _active;
@synthesize taskAvailable = _taskAvailable;

-(instancetype) initAtPosition:(GLKVector3)pos withRotation:(GLKVector3)rot andScale: (GLKVector3)scl onHex:(Hex*)hex
{
    if((self = [super init]))
    {
        
        hex.hexType = ASTEROID;
        _percentSearched = 0.0f;
        _type = [self selectEnvironmentEntityClass];
        _position.x = hex.worldPosition.x;
        _position.y = hex.worldPosition.y;
        _position.z = pos.z;
        _rotation = rot;
        _scale = scl;
        _hex = hex;
        _active = true;
        _powerUp = [self selectPowerUpType];
    }
    return self;

}

- (EnvironmentClasses) selectEnvironmentEntityClass
{
    int value = arc4random()%100 +1;
    
    if (value >= 66.66f)
    {
        return ENV_ASTEROID_VAR2;
    }
    else if (value >= 33.33f)
    {
        return ENV_ASTEROID_VAR1;
    }
    
    return ENV_ASTEROID_VAR0;
}

- (PowerUpType) selectPowerUpType
{
    int value = arc4random()%100 +1;
    
    if (value <= [PowerUp getActionHeroChance])
    {
        return ACTION_HERO;
    }
    else if (value <= [PowerUp getActionHeroChance] + [PowerUp getKaBlamChance])
    {
        return KABLAM;
    }
    else if (value <= [PowerUp getActionHeroChance] + [PowerUp getKaBlamChance] + [PowerUp getLuckyCharmChance])
    {
        return LUCKY_CHARM;
    }
    else if (value <= [PowerUp getActionHeroChance] + [PowerUp getKaBlamChance] + [PowerUp getLuckyCharmChance] + [PowerUp getVampirismChance])
    {
        return VAMPIRISM;
    }
    
    return NOPOWERUP;
}


@end
