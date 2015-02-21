//
//  TaskPump.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
@import QuartzCore;

@interface TaskManager : NSObject

/**
 * Adds a task to the task list.
 * @param task The task to add.
 */
-(void)addTask: (id<Task>) task;

/**
 * Runs all current tasks with the specified delta time (in milliseconds).
 */
-(void)runTasksWithDeltaTime: (CADisplayLink *)link;

@end
