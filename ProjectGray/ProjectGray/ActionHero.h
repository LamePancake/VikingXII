//
//  ActionHero.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-02.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_ActionHero_h
#define ProjectGray_ActionHero_h
#import "PowerUp.h"

@interface ActionHero : PowerUp
@property int actionPointBoost;

- (id) initPowerUpForUnit:(Unit*)unit;
- (void) applyPowerUp;
- (void) endPowerUp;


@end

#endif
