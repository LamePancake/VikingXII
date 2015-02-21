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
 * @param unit        The unit to be moved.
 * @param destination The destination hex cell.
 */
-(instancetype) initWithUnit: (Unit *)unit andDestination: (Hex *)destination;

/**
 * Initialises a task to move the given unit from its current position to the destination and
 * to execute specified task on completion.
 * @param unit        The unit to be moved.
 * @param destination The destination hex cell.
 * @param next        The next task to be executed.
 */
-(instancetype) initWithUnit: (Unit *)unit andDestination: (Hex *)destination andNextTask: (id<Task>)next;

@end
