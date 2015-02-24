//
//  MovementTask.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "MovementTask.h"
#import "HexCells.h"
#import <math.h>

// The speed (in tiles/second)
const double speed = 1;

// Float precision
const double MOVETASK_EPSILON = 0.001;

@interface MovementTask()
{
    double _directionX;
    double _directionY;
    
    Unit* _unit;
    GLKVector3 _destination;
    GLKVector3 _initial;
    BOOL _isFinished;
    id<Task> _next;
}
@end

@implementation MovementTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;

-(instancetype) initWithUnit: (Unit *)unit fromInitial: (Hex*)initialHex toDestination: (Hex *)destination {
    return [self initWithUnit: unit fromInitial:nil toDestination: destination andNextTask: nil];
}

-(instancetype) initWithUnit: (Unit *)unit fromInitial:(Hex*)initCell toDestination:(Hex *)destination andNextTask: (id<Task>)next {
    
    if(self = [super init]) {
        _unit = unit;
        _initial = GLKVector3Make(initCell.worldPosition.x, initCell.worldPosition.y, 0);
        _destination = GLKVector3Make(destination.worldPosition.x, destination.worldPosition.y, 0);
        _directionX = _destination.x - _initial.x;
        _directionY = _destination.y - _initial.y;
        float length = sqrtf(powf(_directionX, 2) + powf(_directionY, 2));
        _directionX = _directionX/length;
        _directionY = _directionY/length;
        _isFinished = NO;
        _next = next;
    }
    return self;
}

-(void) updateWithDeltaTime:(NSTimeInterval)delta {
    double travel = speed * delta;
    
    double xDist = travel * _directionX;
    double yDist = travel * _directionY;
    
    GLKVector3 currentPos = _unit.position;
    GLKVector3 newPos = GLKVector3Make(0, 0, 0);
    
    // Check that we won't pass the requested position
    if(abs(currentPos.x + xDist) > abs(_destination.x)) {
        newPos.x = _destination.x;
        xDist = 0;
    }
    if(abs(currentPos.y + yDist) > abs(_destination.y)) {
        newPos.y = _destination.y;
        yDist = 0;
    }
    
    newPos.x = currentPos.x + xDist;
    newPos.y = currentPos.y + yDist;
    
    // Move the unit and update whether the task is over
    if(newPos.y == _destination.y && newPos.x == _destination.x) _isFinished = YES;
    _unit.position = newPos;
}
@end
