//
//  PickupFlagTask.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-29.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_PickupFlagTask_h
#define ProjectGray_PickupFlagTask_h

#import <Foundation/Foundation.h>
#import "CTFGameMode.h"
#import "Task.h"
#import "Unit.h"
#import "Item.h"
#import "Hex.h"

@interface PickupFlagTask : NSObject <Task>

/**
 * Initialises a task
 * @param u
 * @param vState
 * @param vFlag
 * @param vCarrier
 * @param gState
 * @param gFlag
 * @param gCarrier
 */
-(instancetype) initWithGameObject: (Unit*)u vikingFlagState:(FlagState*)vState vikingFlag:(Item*)vFlag vikingFlagCarrier:(Unit*)vCarrier graysFlagState:(FlagState*)gState graysFlag:(Item*)gFlag graysFlagCarrier:(Unit*)gCarrier;

@end
#endif
