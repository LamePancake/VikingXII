//
//  Hex.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

#import "Hex.h"

@implementation Hex

- (id) initWithAxialCoords:(int)q And:(int)r WithIndex:(int)index AndWorldPosition:(GLKVector2)world
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = GLKVector4Make(1,0,1,1);
        self.instanceVertexIndex = index;
        self.worldPosition = world;
    }
    return self;
}

- (id) initWithAxialCoords:(int)q And:(int)r AndColour:(GLKVector4)colour WithIndex:(int)index AndWorldPosition:(GLKVector2)world
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = colour;
        self.instanceVertexIndex = index;
        self.worldPosition = world;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        // Copy NSObject subclasses
        //[copy setWorldPosition:[[self.worldPosition copyWithZone:zone] autorelease]];
        
        // Set primitives
        [copy setWorldPosition:self.worldPosition];
        [copy setR:self.r];
        [copy setQ:self.q];
        [copy setInstanceVertexIndex:self.instanceVertexIndex];
        [copy setColour:self.colour];
    }
    
    return copy;
}

@end