//
//  RotationTask.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RotationTask.h"

@interface RotationTask()
{
    Unit* _unit;
    GLKVector3 _initial;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
}
@end

@implementation RotationTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;

-(instancetype) initRotateUnit:(Unit *)unit fromAngle:(GLKVector3)currentRot toAngle:(GLKVector3)toRot {
    return [self initRotateUnit:unit fromAngle:currentRot toAngle:toRot andNextTask: nil];
}

-(instancetype) initRotateUnit:(Unit *)unit fromAngle:(GLKVector3)currentRot toAngle:(GLKVector3)toRot andNextTask:(id<Task>)next {
    
    if(self = [super init]) {
        _unit = unit;
        _initial = currentRot;  //We might not actually need this.
        _unit.rotation = (GLKVector3Subtract(_unit.rotation, toRot));
        //We need to actually rotate.  This will done in updateWithDeltaTime.
        _isFinished = NO;
        _next = next;
        _speed *= 0.2f;
        _unit.taskAvailable = false;
    }
    return self;
}

//We need to make a function that rotates the ship on screen and sets flags
-(void) updateWithDeltaTime:(NSTimeInterval)delta {
    //Which we will do here
}

@end