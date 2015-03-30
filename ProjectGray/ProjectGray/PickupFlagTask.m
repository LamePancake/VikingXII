//
//  PickupFlagTask.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-29.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PickupFlagTask.h"

@interface PickupFlagTask()
{
    Unit *unit;
    FlagState *vikingFlagState;
    FlagState *graysFlagState;
    Item* vikingFlag;
    Item* graysFlag;
    Unit* vikingFlagCarrier;
    Unit* graysFlagCarrier;
    
    BOOL _isFinished;
    id<Task> _next;
    NSInvocation* _completion;
}
@end

@implementation PickupFlagTask

@synthesize isFinished = _isFinished;
@synthesize nextTask = _next;
@synthesize completionHandler = _completion;

-(instancetype) initWithGameObject: (Unit*)u vikingFlagState:(FlagState*)vState vikingFlag:(Item*)vFlag vikingFlagCarrier:(Unit*)vCarrier graysFlagState:(FlagState*)gState graysFlag:(Item*)gFlag graysFlagCarrier:(Unit*)gCarrier
{
    if(self = [super init])
    {
        unit = u;
        vikingFlagState = vState;
        vikingFlag = vFlag;
        vikingFlagCarrier = vCarrier;
        
        graysFlagState = gState;
        graysFlag = gFlag;
        graysFlagCarrier = gCarrier;
        _isFinished = false;
    }
    
    return self;
}

-(void) updateWithDeltaTime:(NSTimeInterval)delta
{
    if (unit.faction == VIKINGS)
    {
        if (unit.hex == graysFlag.hex && *graysFlagState == DROPPED) {
            *graysFlagState = TAKEN;
            NSLog(@"Gray flag picked up!");
        }
        else if (unit.hex == vikingFlag.hex && *vikingFlagState == DROPPED) {
            vikingFlagCarrier = unit;
            *vikingFlagState = TAKEN;
            NSLog(@"Viking flag picked up!");
        }
    }
    else
    {
        if (unit.hex == vikingFlag.hex && *vikingFlagState == DROPPED) {
            *vikingFlagState = TAKEN;
            NSLog(@"Viking flag picked up!");
        }
        else if (unit.hex == graysFlag.hex && *graysFlagState == DROPPED) {
            *graysFlagState = TAKEN;
            NSLog(@"Gray flag picked up!");
        }
    }
    _isFinished = true;
}

@end