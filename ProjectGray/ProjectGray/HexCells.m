//
//  HexCells.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//


#import "HexCells.h"

@implementation HexCells
{
    int N;
}

- (id)initWithSize:(int)size_
{
    self = [super init];
    if (self)
    {
        N = size_;
        self.numberOfCells = [self calculateNumberOfCells:size_];
        [self generateCells:size_];
    }
    return self;
}

- (int) calculateNumberOfCells:(int)size_
{
    int hexCount = size_;
    int instances = 0;
    
    // right side of hex
    for (int q = 0; q <= hexCount; ++q)
    {
        for (int r = -hexCount; r <= hexCount - q; ++r)
        {
            instances++;
        }
    }
    // left side of hex
    for (int q = -1; q >= -hexCount; --q)
    {
        for (int r = hexCount; r >= -hexCount - q; --r)
        {
            instances++;
        }
    }
    
    return instances;
}

- (void)insertHex:(Hex*)hex atQ:(int)q AndR:(int)r
{
    NSMutableArray *subArray = [self.hexArray objectAtIndex:q + N];
    [subArray insertObject:hex atIndex:r + N + MIN(0, q)];
}

- (Hex*)hexAtQ:(int)q andR:(int)r
{
    NSMutableArray *subArray = [self.hexArray objectAtIndex:q + N];
    return (Hex*)[subArray objectAtIndex:r + N + MIN(0, q)];
}

- (void) generateCells:(int)size_
{
    int hexCount = size_;
    float size = 0.2;
    float width = size * 1.1f;
    float horiz = width * 3/2;
    float height = sqrt(3)/2 * width;
    float vert = height;
    
    int offset = 0;
    
    self.hexPositions = [[NSMutableArray alloc] initWithCapacity:self.numberOfCells * 2];
    self.hexagons = [[NSMutableArray alloc] initWithCapacity:self.numberOfCells];
    
    //init hex multi-dem array
    self.hexArray = [[NSMutableArray alloc] init];
    
    int arraySize = N * 2 + 1;
    
    for (int i = 0; i < arraySize; i++)
    {
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < arraySize; j++)
        {
            [subArray addObject:[[Hex alloc] initWithAxialCoords:i And:j]];
        }
        [self.hexArray addObject:subArray];
    }
    
    // create hexagons, put them in the multi array
    // right side of hex
    for (int q = 0; q <= hexCount; ++q)
    {
        offset = q;
        for (int r = -hexCount; r <= hexCount - q; ++r)
        {
            Hex *hex; //= [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 1, 0, 1)];
            
            if (r == -1 && q == 1)
            {
                hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 0, 1, 1)];
            }
            else if (r == 0 && q == 0)
            {
                hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(1, 1, 1, 1)];
            }
            else
            {
                hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 1, 0, 1)];
            }
            
            [self insertHex:hex atQ:q AndR:r];
            [self.hexPositions addObject:[NSNumber numberWithFloat:horiz * q]];
            [self.hexPositions addObject:[NSNumber numberWithFloat:(vert * 2) * r + (offset * vert)]];
            
            //[self.hexagons addObject:[[Hex alloc] initWithAxialCoords:q And:r]];
        }
    }
    // left side of hex
    for (int q = -1; q >= -hexCount; --q)
    {
        offset = q;
        for (int r = hexCount; r >= -hexCount - q; --r)
        {
            Hex *hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 1, 0, 1)];
            
            [self insertHex:hex atQ:q AndR:r];
            [self.hexPositions addObject:[NSNumber numberWithFloat:horiz * q]];
            [self.hexPositions addObject:[NSNumber numberWithFloat:(vert * 2) * r + (offset * vert)]];
        }
    }
}

@end