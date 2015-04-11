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

static int actionHeroChance = 12;
static int luckyCharmChance = 6;
static int vampirismChance = 6;
static int kaBlamChance = 3;

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

+ (int) getActionHeroChance
{
    return actionHeroChance;
}

+ (int) getLuckyCharmChance
{
    return luckyCharmChance;
}

+ (int) getVampirismChance
{
    return  vampirismChance;
}

+ (int) getKaBlamChance
{
    return kaBlamChance;
}

@end