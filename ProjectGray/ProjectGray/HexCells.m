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
}

- (id)initWithSize:(int)size_
{
    self = [super init];
    if (self)
    {
        _N = size_;
        _numberOfCells = [self calculateNumberOfCells:size_];
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
    NSMutableArray *subArray = [_hexArray objectAtIndex:q + _N];
    [subArray insertObject:hex atIndex:r + _N + MIN(0, q)];
}

- (Hex*)hexAtQ:(int)q andR:(int)r
{
    NSMutableArray *subArray = [_hexArray objectAtIndex:q + _N];
    return (Hex*)[subArray objectAtIndex:r + _N + MIN(0, q)];
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
    int instanceVertexIndex = 0;
    
    _hexPositions = [[NSMutableArray alloc] initWithCapacity:_numberOfCells * 2];
    
    //init hex multi-dem array
    _hexArray = [[NSMutableArray alloc] init];
    
    int arraySize = _N * 2 + 1;
    
    for (int i = 0; i < arraySize; i++)
    {
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < arraySize; j++)
        {
            [subArray addObject:[[Hex alloc] initWithAxialCoords:i And:j WithIndex:-1]];
        }
        [_hexArray addObject:subArray];
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
                hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 0, 1, 1) WithIndex:instanceVertexIndex];
            }
            else
            {
                hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 1, 0, 1) WithIndex:instanceVertexIndex];
            }
            NSLog(@"At q:%d and r:%d, %d", q, r, hex.instanceVertexIndex);
            
            [self insertHex:hex atQ:q AndR:r];
            [_hexPositions addObject:[NSNumber numberWithFloat:horiz * q]];
            [_hexPositions addObject:[NSNumber numberWithFloat:(vert * 2) * r + (offset * vert)]];
            
            ++instanceVertexIndex;
        }
    }
    
    
    // left side of hex
    for (int q = -hexCount; q <= -1; ++q)
    {
        offset = q;
        for (int r = -hexCount - q; r <= hexCount; ++r)
        {
            Hex *hex = [[Hex alloc] initWithAxialCoords:q And:r AndColour:GLKVector4Make(0, 1, 0, 1) WithIndex:instanceVertexIndex];
            
            [self insertHex:hex atQ:q AndR:r];
            
            [_hexPositions addObject:[NSNumber numberWithFloat:horiz * q]];
            [_hexPositions addObject:[NSNumber numberWithFloat:(vert * 2) * r + (offset * vert)]];
            
            ++instanceVertexIndex;
        }
    }
}

@end