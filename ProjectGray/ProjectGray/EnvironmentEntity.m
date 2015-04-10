//
//  EnvironmentEntity.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnvironmentEntity.h"
#import "ActionHero.h"

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

-(instancetype) initWithType: (EnvironmentClasses) type atPosition:(GLKVector3)pos withRotation:(GLKVector3)rot andScale: (GLKVector3)scl onHex:(Hex*)hex
{
    if((self = [super init]))
    {
        
        hex.hexType = ASTEROID;
        _percentSearched = 0.0f;
        _type = type;
        _position.x = hex.worldPosition.x;
        _position.y = hex.worldPosition.y;
        _position.z = pos.z;
        _rotation = rot;
        _scale = scl;
        _hex = hex;
        _active = true;
        _powerUp = LUCKY_CHARM;
    }
    return self;

}


@end
