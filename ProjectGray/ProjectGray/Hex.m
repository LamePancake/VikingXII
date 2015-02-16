//
//  Hex.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

#import "Hex.h"

@implementation Hex

- (id) initWithAxialCoords:(int)q And:(int)r WithIndex:(int)index
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = GLKVector4Make(1,0,1,1);
        self.instanceVertexIndex = index;
    }
    return self;
}

- (id) initWithAxialCoords:(int)q And:(int)r AndColour:(GLKVector4)colour WithIndex:(int)index
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = colour;
        self.instanceVertexIndex = index;
    }
    return self;
}

- (void) setColour:(GLKVector4)colour
{
    _colour = colour;
}

@end