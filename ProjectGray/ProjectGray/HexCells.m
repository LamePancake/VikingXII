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
    float size;
}

- (id)initWithSize:(int)size_
{
    self = [super init];
    if (self)
    {
        size = 0.2;
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

- (Hex*)hexFromPixelAtX:(int)x andY:(int)y
{
    /*
     function pixel_to_hex(x, y):
     q = x * 2/3 / size
     r = (-x / 3 + sqrt(3)/3 * y) / size
     return hex_round(Hex(q, r))
     */
    
    float qf = x * 2/3 / size;
    float rf = (-x/3 + sqrt(3)/3 * y) / size;
    
    GLKVector2 axialCoord = [self cubeToAxial:[self roundCube:[self axialToCube:qf :rf]]];
    
    int q = axialCoord.x;
    int r = axialCoord.y;
    
    return [self hexAtQ:q andR:r];
}

/*
 function cube_to_hex(h): # axial
 var q = h.x
 var r = h.z
 return Hex(q, r)
 
 function hex_to_cube(h): # axial
 var x = h.q
 var z = h.r
 var y = -x-z
 return Cube(x, y, z)
 */

/*
 function cube_round(h):
 var rx = round(h.x)
 var ry = round(h.y)
 var rz = round(h.z)
 
 var x_diff = abs(rx - h.x)
 var y_diff = abs(ry - h.y)
 var z_diff = abs(rz - h.z)
 
 if x_diff > y_diff and x_diff > z_diff:
 rx = -ry-rz
 else if y_diff > z_diff:
 ry = -rx-rz
 else:
 rz = -rx-ry
 
 return Cube(rx, ry, rz)
 */

-(GLKVector3) roundCube:(GLKVector3) cube
{
    float rx = roundf(cube.x);
    float ry = roundf(cube.y);
    float rz = roundf(cube.z);
    
    float xDiff = abs(rx - cube.x);
    float yDiff = abs(ry - cube.y);
    float zDiff = abs(rz - cube.z);
    
    if ((xDiff > yDiff) && (xDiff > zDiff))
    {
        rx = -ry-rz;
    }
    else if (yDiff > zDiff)
    {
        ry = -rx-rz;
    }
    else
    {
        rz = -rx-ry;
    }
    
    return GLKVector3Make(rx, ry, rz);
}

- (GLKVector2) cubeToAxial:(GLKVector3) cube
{
    float q = cube.x;
    float r = cube.z;
    return GLKVector2Make(q, r);
}

- (GLKVector3) axialToCube:(float)q :(float)r
{
    float x = q;
    float z = r;
    float y = -x-z;
    
    return GLKVector3Make(x, y, z);
}

- (void) generateCells:(int)size_
{
    int hexCount = size_;
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