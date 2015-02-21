//
//  HexCells.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//


#import "HexCells.h"
#import "NSMutableArray+QueueAdditions.h"

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
            [subArray addObject:[[Hex alloc] initWithAxialCoords:i And:j
                                              WithIndex:-1
                                              AndWorldPosition:GLKVector2Make(INT32_MAX, INT32_MAX)]];
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
            
            hex = [[Hex alloc] initWithAxialCoords:q And:r
                                AndColour:GLKVector4Make(0, 1, 0, 1)
                                WithIndex:instanceVertexIndex
                                AndWorldPosition:GLKVector2Make(horiz * q, (vert * 2) * r + (offset * vert))];
            
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
            Hex *hex = [[Hex alloc] initWithAxialCoords:q And:r
                                    AndColour:GLKVector4Make(0, 1, 0, 1)
                                    WithIndex:instanceVertexIndex
                                    AndWorldPosition:GLKVector2Make(horiz * q, (vert * 2) * r + (offset * vert))];
            
            [self insertHex:hex atQ:q AndR:r];
            
            [_hexPositions addObject:[NSNumber numberWithFloat:horiz * q]];
            [_hexPositions addObject:[NSNumber numberWithFloat:(vert * 2) * r + (offset * vert)]];
            
            ++instanceVertexIndex;
        }
    }
}

- (Hex*) closestHexToWorldPosition:(GLKVector2)position WithinHexagon:(BOOL)limit
{
    
    int hexCount = _N;
    Hex *hex;
    float shortestDistance = INT32_MAX;
    float distance = INT32_MAX;
    int closestQ = INT32_MAX;
    int closestR = INT32_MAX;
    
    // right side of hex
    for (int q = 0; q <= hexCount; ++q)
    {
        for (int r = -hexCount; r <= hexCount - q; ++r)
        {
            hex = [self hexAtQ:q andR:r];
            
            if ((distance = GLKVector2Distance(position, hex.worldPosition)) < shortestDistance)
            {
                shortestDistance = distance;
                closestQ = q;
                closestR = r;
            }
        }
    }
    
    // left side of hex
    for (int q = -hexCount; q <= -1; ++q)
    {
        for (int r = -hexCount - q; r <= hexCount; ++r)
        {
            hex = [self hexAtQ:q andR:r];
            
            if ((distance = GLKVector2Distance(position, hex.worldPosition)) < shortestDistance)
            {
                shortestDistance = distance;
                closestQ = q;
                closestR = r;
            }
        }
    }
    
    if (limit && shortestDistance > size)
    {
        return nil;
    }
    else if (shortestDistance == INT32_MAX)
    {
        return nil;
    }
    
    return [self hexAtQ:closestQ andR:closestR];
}

-(NSMutableArray*)movableRange:(int)range from:(Hex *)selectedHex {
    NSMutableArray* withinRange;
    for(int dx = -range; dx <= range; ++dx) {
        for (int dy = MAX(-range, -dx-range); dy <= MIN(range, -dx+range); ++dy) {
            int dz = -dx-dy;
            GLKVector2 axCor = [self cubeToAxial:GLKVector3Make(dx, dy, dz)];
            [[self hexAtQ:axCor.x andR:axCor.y] setColour:GLKVector4Make(1.0f, 0.0f, 0.2f, 1.0f)];
            [withinRange addObject:[self hexAtQ:axCor.x andR:axCor.y]];
        }
    }
    return withinRange;
}

- (BOOL)inRange:(int)q :(int)r
{
    int arraySize = _N * 2 + 1;
    int row = q + _N;
    int column = r + _N + MIN(0, q);
    
    if (row >= arraySize || row < 0)
    {
        return false;
    }
    
    if (column  >= arraySize || column  < 0)
    {
        return false;
    }
    
    return true;
}

- (NSMutableArray*)neighbors:(Hex*)hex
{
    NSMutableArray* neighbors = [[NSMutableArray alloc] init];
    Hex* neighbor;
    
    int q = hex.q;
    int r = hex.r + 1;
    
    if ([self inRange:q :r])
    {
        Hex* neighbor = [self hexAtQ:q andR:r]; // get neighbor at q, r + 1
    
        if (neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    r = hex.r - 1;
    if ([self inRange:q :r])
    {
        neighbor = [self hexAtQ:q andR:r]; // get neighbor at q, r - 1
        
        if (neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    q = hex.q + 1;
    r = hex.r - 1;
    if ([self inRange:q :r])
    {
        neighbor = [self hexAtQ:q andR:r]; // get neighbor at q + 1, r - 1
        
        if ([self inRange:q :r] && neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    r = hex.r;
    if ([self inRange:q :r])
    {
        neighbor = [self hexAtQ:q andR:r]; // get neighbor at q + 1, r
        
        if (neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    q = hex.q - 1;
    r = hex.r;
    if ([self inRange:q :r])
    {
        neighbor = [self hexAtQ:q andR:r]; // get neighbor at q - 1, r
        
        if (neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    r = hex.r + 1;
    if ([self inRange:q :r])
    {
        neighbor = [self hexAtQ:q andR:r]; // get neighbor at q - 1, r + r
        
        if (neighbor.instanceVertexIndex != -1)
        {
            [neighbors addObject:neighbor];
        }
    }
    
    return neighbors;
}

- (NSMutableArray*)makePathFrom:(int)q1 :(int)r1 To:(int)q2 :(int)r2
{
    Hex *start = [self hexAtQ:q1 andR:r1];
    Hex *goal = [self hexAtQ:q2 andR:r2];
    
    NSMutableArray* frontierQueue = [[NSMutableArray alloc] init];
    
    [frontierQueue enqueue:start];
    NSMutableDictionary* cameFrom = [[NSMutableDictionary alloc] init];
    [cameFrom setObject:start forKey:[NSNumber numberWithInt:start.hash]];
    Hex* current;
    NSMutableArray* neighbors;
    
    while (!frontierQueue.empty) {
        current = [frontierQueue dequeue];
        neighbors = [self neighbors:current];
        for (id next in neighbors)
        {
            if ([cameFrom objectForKey:[NSNumber numberWithInt:((Hex*)next).hash]] == nil)
            {
                [frontierQueue enqueue:next];
                [cameFrom setObject:current forKey:[NSNumber numberWithInt:((Hex*)next).hash]];
            }
        }
    }
    
    NSMutableArray* path = [[NSMutableArray alloc] init];
    current = goal;
    [path addObject:current];
    
    while (current != start) {
        current = cameFrom[[NSNumber numberWithInt:(current).hash]];
        [path addObject:current];
    }
    
    return path;
}

@end