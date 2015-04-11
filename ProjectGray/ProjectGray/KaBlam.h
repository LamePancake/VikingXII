//
//  KaBlam.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-11.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_KaBlam_h
#define ProjectGray_KaBlam_h
#import "PowerUp.h"

@interface KaBlam : PowerUp
@property float unitsPreviousAccuracy;
@property float unitsPreviousDamage;
@property float unitsPreviousAttackRange;
@property float unitsPreviousActionPointAttackCost;

- (id) initPowerUpForUnit:(Unit*)unit;
- (void) applyPowerUp;
- (void) endPowerUp;

@end

#endif
