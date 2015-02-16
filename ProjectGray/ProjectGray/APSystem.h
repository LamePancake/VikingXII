//
//  APSystem.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//
#import "GameObject.h"

//Anything that gets passed to APSystem should already be "legal"
//
@interface APSystem : NSObject
{

}
+(int)moveThis:(GameObject*)mover thisDirection:(int)direction thisAmount:(int)magnitude; //Placeholder for GameObjectMovement
+(int)attackThis:(GameObject*)defender with:(GameObject*)attacker;
+(int)refillAPFor:(GameObject*)thisObject;//This should be called at beginning of turn for all GameObjects
+(int)healThis:(GameObject*)target byThis:(GameObject*)healer;
@end