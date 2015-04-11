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
 * If specified, this completion handler will be run when the task finishes.
 */
@property (strong, nonatomic) NSArray* completionHandler;

/**
 * Whether this task is finished.
 */
@property (nonatomic, readonly) BOOL isFinished;

/**
 * Updates the task with the time since the last frame.
 * @discussion The task will perform whatever function (animation, etc.) over the given time period.
 * @param delta The time interval since the last time (in seconds).
 */
-(void)updateWithDeltaTime: (NSTimeInterval)delta;

@end
