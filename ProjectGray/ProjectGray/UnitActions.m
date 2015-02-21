//
//  UnitActions.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnitActions.h"

@interface UnitActions ()

@end

@implementation UnitActions
+(int)moveThis:(Unit *)mover toHex:(Hex *)hex{
    return 1;
}
+(int)attackThis:(Unit*)defender with:(Unit *)attacker {
    return 1;
}
+(int)refillAPFor:(Unit *)thisObject{
    return 1;
}
+(int)healThis:(Unit *)target byThis:(Unit *)healer{
    return 1;
}
@end