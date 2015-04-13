//
//  StrikeTask.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-03-29.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "StrikeTask.h"
#import "SoundManager.h"

@interface StrikeTask()
{
    id<Task> _nextTask;
    NSMutableArray* _completion;
    BOOL _isFinished;
    
    id<GameObject> _projectile;
    id<GameObject> _target;
    Game* _game;
    NSString* _soundFile;
}
@end

@implementation StrikeTask

@synthesize nextTask = _nextTask;
@synthesize completionHandler = _completion;
@synthesize isFinished = _isFinished;

-(instancetype) initWithProjectile: (id<GameObject>)projectile andTarget: (id<GameObject>)target andGame: (Game*) game withSound: (NSString*)soundFile
{
    return [self initWithProjectile:projectile andTarget:target andGame:game withSound:soundFile andNextTask:nil andCompletionHandlers:nil];
}

-(instancetype) initWithProjectile: (id<GameObject>)projectile andTarget:(id<GameObject>)target andGame:(Game *)game withSound:(NSString *)soundFile
                       andNextTask: (id<Task>)task
{
    return [self initWithProjectile:projectile andTarget:target andGame:game withSound:soundFile andNextTask:task andCompletionHandlers:nil];
}

-(instancetype) initWithProjectile:(id<GameObject>)projectile andTarget:(id<GameObject>)target andGame:(Game *)game withSound:(NSString *)soundFile
                       andNextTask:(id<Task>)task andCompletionHandlers: (NSMutableArray*)completionHandlers
{
    if((self = [super init]))
    {
        _nextTask = task;
        _completion = [[NSMutableArray alloc] init];
        [_completion addObjectsFromArray:completionHandlers];
        _isFinished = NO;
        
        _projectile = projectile;
        _target = target;
        _game = game;
        _soundFile = soundFile;
    }
    
    return self;
}

/**
 * Updates the task with the time since the last frame.
 * @discussion The task will perform whatever function (animation, etc.) over the given time period.
 * @param delta The time interval since the last time (in seconds).
 */
-(void)updateWithDeltaTime: (NSTimeInterval)delta
{
    [[SoundManager sharedManager] playSound:_soundFile looping:NO];
    _projectile.active = NO;
    _isFinished = YES;
}

@end
