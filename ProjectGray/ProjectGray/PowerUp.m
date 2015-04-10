//
//  PowerUp.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-02.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PowerUp.h"

@implementation PowerUp

- (instancetype) initPowerUpForUnit:(Unit*)unit forThisManyRounds:(int)num
{
    self = [super init];
    if (self)
    {
        _numOfRounds = num;
        _affectedUnit = unit;
    }
    return self;
}

- (void) applyPowerUp
{
}

- (void) endPowerUp
{
}

@end