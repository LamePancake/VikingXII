//
//  RotationTask.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RotationTask.h"

// Rotation directions
#define CCW 1
#define CW  -1

// Units start facing 90 degrees
// TODO: Change the model, pass this as a parameter, or add it to GameObject so that
//       we can rotate other things with this task.
#define UNIT_ZROT_OFF -(M_PI / 2)

@interface RotationTask()
{
    id<GameObject> _obj;
    GLKVector3 _endAngle;
    BOOL _isFinished;
    id<Task> _next;
    double _speed;
    
    int _rotationDirection;
    NSInvocation* _completion;
}
@end

@implementation RotationTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;
@synthesize completionHandler = _completion;

-(instancetype) initWithGameObject: (id<GameObject>)obj toAngle:(GLKVector3)toRot {
    return [self initWithGameObject:obj toAngle:toRot andNextTask: nil];
}

-(instancetype) initWithGameObject: (id<GameObject>)obj toAngle:(GLKVector3)toRot andNextTask:(id<Task>)next {
    
    if(self = [super init]) {
        _obj = obj;
        _obj.rotation = [RotationTask clampRotation: obj.rotation];
        _endAngle = toRot;
        _isFinished = NO;
        _next = next;
        _speed = 3;
        _obj.taskAvailable = false;
        _rotationDirection = 0;
        _endAngle = [RotationTask clampRotation:_endAngle];
        
        float rotationOffset = 0;
        
        if([(id)obj isMemberOfClass:[Unit class]])
        {
            rotationOffset = UNIT_ZROT_OFF;
        }
        
        _endAngle.z += rotationOffset;
        _endAngle = [RotationTask clampRotation:_endAngle];
        
        // I'm just going to implement this for z rotations for the time being, but this
        // calculation ought to be done for everything
        float angleDelta = fabs(_endAngle.z - _obj.rotation.z);
        
        // Want to make the rotation the shortest possible, so adjust the end rotation such that
        // we always rotation <= 180 degrees
        if(_endAngle.z < _obj.rotation.z)
        {
            if(angleDelta < M_PI) _rotationDirection = CW;
            else
            {
                _endAngle.z += M_PI * 2;
                _rotationDirection = CCW;
            }
        }
        else
        {
            if(angleDelta < M_PI) _rotationDirection = CCW;
            else
            {
                _endAngle.z -= M_PI * 2;
                _rotationDirection = CW;
            }
        }
    }
    return self;
}

//We need to make a function that rotates the ship on screen and sets flags
-(void) updateWithDeltaTime:(NSTimeInterval)delta {
//    In each update, multiply rotation direction * speed * deltaTime to calculate rotation
    
    float rotThisUpdate = _rotationDirection * _speed * delta;
    float deltaToEnd = _endAngle.z - _obj.rotation.z;
    GLKVector3 newRot = GLKVector3Make(_obj.rotation.x, _obj.rotation.y, _obj.rotation.z + rotThisUpdate);
    
    // If the amount by which the object will rotate this frame is greater than the remaining rotation, we're done
    // Also clamp the rotation again for consistency
    if(fabs(rotThisUpdate) > fabs(deltaToEnd))
    {
        _isFinished = YES;
        newRot = GLKVector3Make(_obj.rotation.x, _obj.rotation.y, _obj.rotation.z + deltaToEnd);
        newRot = [RotationTask clampRotation:newRot];
    }
    
    _obj.rotation = newRot;
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