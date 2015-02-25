//
//  UnitActions.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"
#import "Hex.h"
#import "HexCells.h"
#import "Task.h"
#import "MovementTask.h"

static NSString *attackInfo;

//Anything that gets passed to APSystem should already be "legal"
//
@interface UnitActions : NSObject
{
}
+(void)moveThis:(Unit*)mover toHex:(Hex*)hex onMap: (HexCells*)map; //GameObjectMovement

/**
 * Calculates the damage done on the target based on the attackers 
 * stats/state and decrements it from the targets health.
 * @param attacker is the unit who's currently attacking the target
 * @param target is the unit being attacked by the attacker
 */
+(void)attackThis:(Unit*)target with:(Unit*)attacker;
+(void)refillAPFor:(Unit*)thisObject;//This should be called at beginning of turn for all GameObjects
+(void)healThis:(Unit*)target byThis:(Unit*)healer;
+(NSMutableArray*)getCurrentPath;
+(NSString*) getAttackInfo;
+ (void) setAttackInfo:(NSString*)info;
@end