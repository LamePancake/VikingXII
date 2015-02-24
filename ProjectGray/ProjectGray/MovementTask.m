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
const double speed = 3;

// Float precision
const double MOVETASK_EPSILON = 0.001;

@interface MovementTask()
{
    GLKVector2 _direction;
    Unit* _unit;
    GLKVector3 _destination;
    GLKVector3 _initial;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
}
@end

@implementation MovementTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;

-(instancetype) initWithUnit: (Unit *)unit fromInitial: (Hex*)initialHex toDestination: (Hex *)destination {
    return [self initWithUnit: unit fromInitial:initialHex toDestination: destination andNextTask: nil];
}

-(instancetype) initWithUnit: (Unit *)unit fromInitial:(Hex*)initCell toDestination:(Hex *)destination andNextTask: (id<Task>)next {
    
    if(self = [super init]) {
        _unit = unit;
        _initial = GLKVector3Make(initCell.worldPosition.x, initCell.worldPosition.y, unit.position.z);
        _destination = GLKVector3Make(destination.worldPosition.x, destination.worldPosition.y, unit.position.z);
        _direction = GLKVector2Normalize(GLKVector2Make(_destination.x - initCell.worldPosition.x, _destination.y - initCell.worldPosition.y));
        _isFinished = NO;
        _next = next;
        _speed = speed * 0.2; // The scale of the hex cells; TODO: not hardcode this
    }
    return self;
}

-(void) updateWithDeltaTime:(NSTimeInterval)delta {
    double travel = _speed * delta;
    
    double xDist = travel * _direction.x;
    double yDist = travel * _direction.y;
    
    GLKVector3 currentPos = _unit.position;
    GLKVector3 newPos = GLKVector3Make(0, 0, _unit.position.z);
    
    newPos.x = currentPos.x + xDist;
    newPos.y = currentPos.y + yDist;
    
    // Check that we won't pass the requested position
    
    double length = GLKVector2Length(GLKVector2Make(_destination.x - newPos.x, _destination.y - newPos.y));
    
    if(length <= 0.03f) {
        _isFinished = YES;
        newPos.x = _destination.x;
        newPos.y = _destination.y;
    }
    
    _unit.position = newPos;
}

@end
