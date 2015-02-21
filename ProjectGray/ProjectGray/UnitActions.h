//
//  UnitActions.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"
#import "Hex.h"
//Anything that gets passed to APSystem should already be "legal"
//
@interface UnitActions : NSObject
{
    
}
+(int)moveThis:(Unit*)mover toHex:(Hex*)hex; //GameObjectMovement
+(float)attackThis:(Unit*)defender with:(Unit*)attacker;
+(int)refillAPFor:(Unit*)thisObject;//This should be called at beginning of turn for all GameObjects
+(int)healThis:(Unit*)target byThis:(Unit*)healer;
@end