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
    NSMutableArray *_emptySlots;
    NSMutableArray* _taskList;
}

@end

@implementation TaskManager

-(instancetype) init {
    
    if(self = [super init]) {
        _taskList = [[NSMutableArray alloc] initWithCapacity:64]; // 64 is just for fun (apparently I'll only get 16 anyway)
        _emptySlots = [[NSMutableArray alloc] initWithCapacity:16];
    }
    
    return self;
}

-(void)runTasksWithDeltaTime: (double)delta
{
    int numTasks = [_taskList count];
    for(int i = 0; i < numTasks; i++)
    {
        id<Task> curTask = _taskList[i];
        
        // If there isn't a task at this slot, don't bother
        if(!curTask) continue;
        
        [curTask updateWithDeltaTime:delta];
        
        // Replace the current task with the next one in the list (if it exists)
        // Otherwise, add this slot to the list of empty slots
        if(curTask.isFinished) {
            id<Task>next = curTask.nextTask;

            if(next) _taskList[i] = next;
            else [_emptySlots addObject: [[NSNumber alloc] initWithInt:i]];
        }
    }
}

-(void) addTask: (id<Task>) task {
    
    // Try to add it to a previously empty slot first; don't want to bloat the array
    if([_emptySlots count] != 0) {
        NSNumber* slot = [_emptySlots lastObject];
        _taskList[[slot intValue]] = task;
        [_taskList removeLastObject];
    } else {
        [_taskList addObject: task];
    }
}
@end
