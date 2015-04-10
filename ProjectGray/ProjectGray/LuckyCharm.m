//
//  LuckyCharm.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyCharm.h"

@implementation LuckyCharm

- (void) applyPowerUp
{
    self.affectedUnit.stats->critChance = 100;
}

- (void) endPowerUp
{
    self.affectedUnit.stats->critChance = self.unitsPreviousCritChance;
}

- (id) initPowerUpForUnit:(Unit*)unit
{
    self = [super init];
    if (self)
    {
        self.affectedUnit = unit;
        self.unitsPreviousCritChance = unit.stats->critChance;
        self.numOfRounds = 3;
    }
    return self;
}

@end