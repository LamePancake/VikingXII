//
//  ActionHero.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-02.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionHero.h"

@implementation ActionHero

- (void) applyPowerUp
{
    self.affectedUnit.stats->actionPool += _actionPointBoost;
    self.affectedUnit.powerUp |= ACTION_HERO;
}

- (void) endPowerUp
{
    self.affectedUnit.powerUp ^= ACTION_HERO;
}


- (id) initPowerUpForUnit:(Unit*)unit
{
    self = [super init];
    if (self)
    {
        self.affectedUnit = unit;
        self.actionPointBoost = 4;
        self.numOfRounds = 0;
    }
    return self;
}

@end