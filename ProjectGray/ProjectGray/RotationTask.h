//
//  RotationTask.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "Unit.h"

@interface RotationTask : NSObject <Task>

/**
 * Initialises a task to rotate the unit to a new angle.
 * @param unit        The unit to be rotated.
 * @param toAngle     The new rotation of the unit.
 */
-(instancetype) initRotateUnit: (Unit *)unit fromAngle: (GLKVector3)currentRot toAngle: (GLKVector3)toRot;

/**
 * Initialises a task to rotate the unit to a new angle and to execute specified task on completion.
 * @param unit        The unit to be rotated.
 * @param toAngle     The new rotation of the unit.
 * @param next        The next task to be executed.
 */
-(instancetype) initRotateUnit: (Unit *)unit fromAngle: (GLKVector3)currentRot toAngle: (GLKVector3)toRot andNextTask: (id<Task>)next;

@end