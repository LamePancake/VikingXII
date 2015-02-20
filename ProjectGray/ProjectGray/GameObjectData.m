//
//  GameObjectData.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectData.h"

@interface GameObjectData ()

@end

@implementation GameObjectData

-(id) initWithValues:(int)movePerAP {
    moveSpeed = movePerAP;
    return self;
}

-(int) getMoveSpeed {
    return moveSpeed;
}

@end