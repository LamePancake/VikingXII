//
//  KaBlam.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-11.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaBlam.h"

@implementation KaBlam

- (void) applyPowerUp
{
    self.affectedUnit.stats->damage = (float)INT32_MAX;
    self.affectedUnit.stats->accuracy = 1.0f;
    self.affectedUnit.stats->attackRange = 42;
    self.affectedUnit.stats->actionPointsPerAttack = -1;
    self.affectedUnit.powerUp |= KABLAM;
}

- (void) endPowerUp
{
    self.affectedUnit.stats->accuracy = self.unitsPreviousAccuracy;
    self.affectedUnit.stats->damage = self.unitsPreviousDamage;
    self.affectedUnit.stats->attackRange = self.unitsPreviousAttackRange;
    self.affectedUnit.stats->actionPointsPerAttack = self.unitsPreviousActionPointAttackCost;
    self.affectedUnit.powerUp ^= KABLAM;
}

- (id) initPowerUpForUnit:(Unit*)unit
{
    self = [super init];
    if (self)
    {
        self.affectedUnit = unit;
        self.unitsPreviousAccuracy = unit.stats->accuracy;
        self.unitsPreviousAttackRange = unit.stats->attackRange;
        self.unitsPreviousDamage = unit.stats->damage;
        self.unitsPreviousActionPointAttackCost = unit.stats->actionPointsPerAttack;
        self.numOfRounds = 0;
    }
    return self;
}

@end