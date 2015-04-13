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
    id<GameObject> _obj;
    GLKVector3 _endAngle;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
    NSMutableArray* _completion;
}
@end

@implementation RotationTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;
@synthesize completionHandler = _completion;

-(instancetype) initWithGameObject: (id<GameObject>)obj toAngle:(GLKVector3)toRot {
    return [self initWithGameObject:obj toAngle:toRot andNextTask: nil];
}

-(instancetype) initWithGameObject: (id<GameObject>)obj toAngle:(GLKVector3) toRot andNextTask:(id<Task>)next {
    
    if(self = [super init]) {
        _obj = obj;
        _obj.rotation = [RotationTask clampRotation: obj.rotation];
        _endAngle = toRot;
        _isFinished = NO;
        _next = next;
        _speed = 3;
        _obj.taskAvailable = false;
        _endAngle = [RotationTask clampRotation:_endAngle];
        _completion = [[NSMutableArray alloc] init];
        _endAngle = [RotationTask clampRotation:_endAngle];
        
        // I'm just going to implement this for z rotations for the time being, but this
        // calculation ought to be done for everything
        float angleDelta = fabs(_endAngle.z - _obj.rotation.z);
        
        // Want to make the rotation the shortest possible, so adjust the end rotation such that
        // we always rotation <= 180 degrees
        if(_endAngle.z < _obj.rotation.z)
        {
            if(angleDelta >= M_PI)
            {
                _endAngle.z += M_PI * 2;
            }
        }
        else
        {
            if(angleDelta >= M_PI)
            {
                _endAngle.z -= M_PI * 2;
            }
        }
    }
    return self;
}

//We need to make a function that rotates the ship on screen and sets flags
-(void) updateWithDeltaTime:(NSTimeInterval)delta {

    float current = [self lerpFrom:_obj.rotation.z to:_endAngle.z withValue:(delta * _speed)];
    
    if ((fabs((current) - (_endAngle.z)) <= 0.0327f))
    {
        current = _endAngle.z;
        _isFinished = YES;
    }
    _obj.rotation = GLKVector3Make(_obj.rotation.x, _obj.rotation.y, current);
    
}

//Interpolates between a and b by t. t is clamped between 0 and 1.
-(float)lerpFrom:(float)from to:(float)to withValue:(float)value
{
    if (value < 0.0f)
        return from;
    else if (value > 1.0f)
        return to;
    return (to - from) * value + from;
}

/**
 * Clamps rotation between [0, 2 * PI].
 * @param rotVector The vector specifying the XYZ rotations to be clamped.
 */
+ (GLKVector3)clampRotation: (GLKVector3)rotVector
{
    // Ensure that the object's rotation stays between [0, 2 * PI)
    GLKVector3 clampedRot = GLKVector3Make(rotVector.x >= (M_PI * 2) ? rotVector.x - (M_PI * 2) : rotVector.x,
                                           rotVector.y >= (M_PI * 2) ? rotVector.y - (M_PI * 2) : rotVector.y,
                                           rotVector.z >= (M_PI * 2) ? rotVector.z - (M_PI * 2) : rotVector.z);
    clampedRot.x = clampedRot.x < 0 ? (M_PI * 2) + clampedRot.x : clampedRot.x;
    clampedRot.y = clampedRot.y < 0 ? (M_PI * 2) + clampedRot.y : clampedRot.y;
    clampedRot.z = clampedRot.z < 0 ? (M_PI * 2) + clampedRot.z : clampedRot.z;
    
    return clampedRot;
}

@end