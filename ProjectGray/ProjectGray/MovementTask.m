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
    id<GameObject> _obj;
    GLKVector3 _destination;
    GLKVector3 _initial;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
    NSInvocation* _completion;
}
@end

@implementation MovementTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;
@synthesize completionHandler = _completion;

-(instancetype) initWithGameObject: (id<GameObject>)obj fromInitial: (GLKVector3)initialPos toDestination: (GLKVector3)destination {
    return [self initWithGameObject: obj fromInitial:initialPos toDestination: destination andNextTask: nil];
}

-(instancetype) initWithGameObject: (id<GameObject>)obj fromInitial:(GLKVector3)initPos toDestination:(GLKVector3)destination andNextTask: (id<Task>)next {
    
    if(self = [super init]) {
        _obj = obj;
        _initial = initPos;
        _destination = GLKVector3Make(destination.x, destination.y, initPos.z);
        _direction = GLKVector2Normalize(GLKVector2Make(_destination.x - initPos.x, _destination.y - initPos.y));
        _isFinished = NO;
        _next = next;
        _speed = speed * 0.2; // The scale of the hex cells; TODO: not hardcode this
        _obj.taskAvailable = false;
    }
    return self;
}

-(void) updateWithDeltaTime:(NSTimeInterval)delta {
    double travel = _speed * delta;
    
    double xDist = travel * _direction.x;
    double yDist = travel * _direction.y;
    
    GLKVector3 currentPos = _obj.position;
    GLKVector3 newPos = GLKVector3Make(0, 0, _obj.position.z);
    
    newPos.x = currentPos.x + xDist;
    newPos.y = currentPos.y + yDist;
    
    // Check that we won't pass the requested position
    
    double length = GLKVector2Length(GLKVector2Make(_destination.x - newPos.x, _destination.y - newPos.y));
    
    // Also don't want to hard code this if possible
    if(length <= 0.03f) {
        _isFinished = YES;
        newPos.x = _destination.x;
        newPos.y = _destination.y;
    }
    
    _obj.position = newPos;
}

@end
