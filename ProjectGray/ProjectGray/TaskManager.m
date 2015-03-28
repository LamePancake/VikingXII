//
//  TaskPump.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "TaskManager.h"
#import "Task.h"

@interface TaskManager()
{
    NSMutableArray* _taskList;
    
    CFTimeInterval _prevTime;
    CFTimeInterval _curTime;
}

@end

@implementation TaskManager

-(instancetype) init {
    
    if(self = [super init]) {
        _taskList = [[NSMutableArray alloc] initWithCapacity:64]; // 64 is just for fun (apparently I'll only get 16 anyway)
        _prevTime = 0;
        _curTime = 0;
    }
    
    return self;
}

-(void)runTasksWithCurrentTime: (NSTimeInterval) time
{
    _prevTime = _curTime;
    _curTime = time;
    CFTimeInterval delta = _curTime - _prevTime;
    
    NSUInteger numTasks = [_taskList count];
    for(NSUInteger i = 0; i < numTasks; i++)
    {
        id<Task> curTask = _taskList[i];
        [curTask updateWithDeltaTime: delta];
        
        // Replace the current task with the next one in the list (if it exists)
        // and invoke its completion handler if it has one
        if(curTask.isFinished) {
            // Invoke the completion handler, if any
            [curTask.completionHandler invoke];
            id<Task>next = curTask.nextTask;
            
            if(next) _taskList[i] = next;
            else [_taskList removeObjectAtIndex: i];
        }
        // Need to update task count; if there were multiple running at the same time and one was removed, it could go out of bounds
        numTasks = [_taskList count];
    }
}

-(void) addTask: (id<Task>) task {
    [_taskList addObject: task];
}
@end
