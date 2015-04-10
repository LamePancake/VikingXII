//
//  Vampirism.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vampirism.h"

@implementation Vampirism

- (void) applyPowerUp
{
    self.affectedUnit.powerUp = VAMPIRISM;
}

- (void) endPowerUp
{
    self.affectedUnit.powerUp = NOPOWERUP;
}

- (id) initPowerUpForUnit:(Unit*)unit
{
    self = [super init];
    if (self)
    {
        self.affectedUnit = unit;
        self.numOfRounds = 3;
    }
    return self;
}

@end