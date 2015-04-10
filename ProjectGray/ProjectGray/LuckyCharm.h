//
//  LuckyCharm.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_LuckyCharm_h
#define ProjectGray_LuckyCharm_h
#import "PowerUp.h"

@interface LuckyCharm : PowerUp
@property float unitsPreviousCritChance;

- (id) initPowerUpForUnit:(Unit*)unit;
- (void) applyPowerUp;
- (void) endPowerUp;

@end

#endif
