//
//  StrikeTask.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-03-29.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Task.h"
#import "Game.h"

@class Game;

@interface StrikeTask : NSObject <Task>

@property(strong, nonatomic) NSString* soundFile;

-(instancetype) initWithProjectile: (id<GameObject>)projectile andTarget: (id<GameObject>)target andGame: (Game *)game withSound: (NSString*)soundFile;
-(instancetype) initWithProjectile: (id<GameObject>)projectile andTarget:(id<GameObject>)target andGame:(Game *)game withSound:(NSString *)soundFile
                       andNextTask: (id<Task>)task;
-(instancetype) initWithProjectile:(id<GameObject>)projectile andTarget:(id<GameObject>)target andGame:(Game *)game withSound:(NSString *)soundFile
                       andNextTask:(id<Task>)task andCompletionHandlers: (NSMutableArray*)completionHandlers;
@end
