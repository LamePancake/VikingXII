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
    int _directionSigns[2];
    GLKVector3 _destination;
    GLKVector3 _initial;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
    NSMutableArray* _completion;
}

@property (strong, nonatomic) id<GameObject> obj;

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
        _directionSigns[0] = _direction.x / fabs(_direction.x);
        _directionSigns[1] = _direction.y / fabs(_direction.y);
        _isFinished = NO;
        _next = next;
        _speed = speed * 0.2; // The scale of the hex cells; TODO: not hardcode this
        _obj.taskAvailable = false;
        _completion = [[NSMutableArray alloc] init];
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
    
    GLKVector2 curDirection = GLKVector2Make(_destination.x - newPos.x, _destination.y - newPos.y);
    int curSigns[2] = {curDirection.x / fabs(curDirection.x), curDirection.y / fabs(curDirection.y)};
    
    // Check whether x and y still point in the same direction as when we first calculated the direction
    // If either of them doesn't match, then we've gone past the objective (or hit it) and need to stop
    if(curSigns[0] != _directionSigns[0] || curSigns[1] != _directionSigns[1]) {
        _isFinished = YES;
        newPos.x = _destination.x;
        newPos.y = _destination.y;
    }
    
    _obj.position = newPos;
}

@end
