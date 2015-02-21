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
    double _cosTheta;
    double _sinTheta;
    
    Unit* _unit;
    GLKVector3 _destination;
    BOOL _isFinished;
    id<Task> _next;
}
@end

@implementation MovementTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;

-(instancetype) initWithUnit: (Unit *)unit andDestination: (Hex *)destination {
    return [self initWithUnit: unit andDestination: destination andNextTask: nil];
}

-(instancetype) initWithUnit: (Unit *)unit andDestination: (Hex *)destination andNextTask: (id<Task>)next {
    
    if(self = [super init]) {
        _unit = unit;
        _destination = GLKVector3Make(destination.worldPosition.x, destination.worldPosition.y, 0);
        _isFinished = NO;
        _next = next;
        _cosTheta = cos(unit.rotation.y);
        _sinTheta = sin(unit.rotation.y);
    }
    return self;
}

-(void) updateWithDeltaTime:(CFTimeInterval)delta {
    double travel = speed * delta;
    
    double xDist = travel * _cosTheta;
    double yDist = travel * _sinTheta;
    
    GLKVector3 currentPos = _unit.position;
    GLKVector3 newPos = GLKVector3Make(0, 0, 0);
    
    // Check that we won't pass the requested position
    if(abs(currentPos.x + xDist) > abs(_destination.x) + MOVETASK_EPSILON) {
        newPos.x = _destination.x;
        xDist = 0;
    }
    if(abs(currentPos.y + yDist) > abs(_destination.y) + MOVETASK_EPSILON) {
        newPos.y = _destination.y;
        yDist = 0;
    }
    
    newPos.x = currentPos.x + xDist;
    newPos.y = currentPos.y + yDist;
    
    // Move the unit and update whether the task is over
    if(abs(newPos.y - _destination.y) < MOVETASK_EPSILON && (newPos.x - _destination.x) < MOVETASK_EPSILON) _isFinished = YES;
    _unit.position = newPos;
}
@end
