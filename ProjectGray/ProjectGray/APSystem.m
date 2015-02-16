//
//  APSystem.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSystem.h"

@interface APSystem ()

@end

@implementation APSystem
+(int)moveThis:(GameObject *)mover thisDirection:(int)direction thisAmount:(int)magnitude {
    
    return 1;
}
+(int)attackThis:(GameObject *)defender with:
(GameObject *)attacker {
    return 1;
}
+(int)refillAPFor:(GameObject *)thisObject{
    return 1;
}
+(int)healThis:(GameObject *)target byThis:(GameObject *)healer{
    return 1;
}
@end