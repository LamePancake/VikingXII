//
//  Task.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Task

/**
 * Specifies the task (if any) to be run after this task has finished.
 */
@property (strong, nonatomic) id<Task> nextTask;

/**
 * Whether this task is finished.
 */
@property (nonatomic, readonly) BOOL isFinished;

/**
 * Updates the task with the time since the last frame.
 * @discussion The task will perform whatever function (animation, etc.) over the given time period.
 * @param delta The time interval since the last time (in milliseconds).
 */
-(void)updateWithDeltaTime: (double)delta;

@end