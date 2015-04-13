//
//  Item.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Item.h"

const float ITEM_SCALE = 0.01f;
const float ITEM_HEIGHT = 0.04f;
const float PROJECTILE_SCALE = 0.0075f;

@interface Item ()
{
    //ItemStats _shipStats;
}

@property int actionsPerRound; //How much AP this unit should have each round
@end

@implementation Item

@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize scale = _scale;
@synthesize taskAvailable = _taskAvailable;
@synthesize active = _active;

-(instancetype) initWithFaction: (Faction)faction andClass: (ItemClasses)itemClass atPosition:(GLKVector3)atPos withRotation:(GLKVector3)itemRot andScale: (GLKVector3)scl
                          onHex:(Hex*)hex {
    if((self = [super init])) {
        _position = atPos;
        _rotation = itemRot;
        _scale = scl;
        _itemClass = itemClass;
        _faction = faction;
        _position = atPos;
        _rotation = itemRot;
        _hex = hex;
        _modelData = factionModels[faction][itemClass];
        _modelArrSize = factionVertexCounts[faction][itemClass] * VERTEX_SIZE;
        _numModelVerts = factionVertexCounts[faction][itemClass];
        _active = true;
        _taskAvailable = true;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    Item* copy = [[Item alloc] initWithFaction:_faction andClass:_itemClass atPosition:_position withRotation:_rotation andScale:_scale onHex:_hex];
    copy.active = false;
    return copy;
}

@end
