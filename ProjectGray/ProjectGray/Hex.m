//
//  Hex.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

#import "Hex.h"

@implementation Hex

- (id) initWithAxialCoords:(int)q And:(int)r
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = GLKVector4Make(1,0,1,1);
    }
    return self;
}

- (id) initWithAxialCoords:(int)q And:(int)r AndColour:(GLKVector4)colour
{
    self = [super init];
    if (self)
    {
        self.r = r;
        self.q = q;
        self.colour = colour;
    }
    return self;
}

@end