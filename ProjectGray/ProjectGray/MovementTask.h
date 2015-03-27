//
//  MovementTask.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "Unit.h"
#import "Hex.h"

@interface MovementTask : NSObject <Task>

/**
 * Initialises a task to move the given unit from its current position to the destination.
 * @param obj         The GameObject to be moved.
 * @param destination The destination position.
 */
-(instancetype) initWithGameObject: (id<GameObject>)obj fromInitial: (GLKVector3)initialPos toDestination: (GLKVector3)destination;

/**
 * Initialises a task to move the given unit from its current position to the destination and
 * to execute specified task on completion.
 * @param obj         The GameObject to be moved.
 * @param destination The destination position.
 * @param next        The next task to be executed.
 */
-(instancetype) initWithGameObject: (id<GameObject>)obj fromInitial:(GLKVector3)initPos toDestination:(GLKVector3)destination andNextTask: (id<Task>)next;
@end
