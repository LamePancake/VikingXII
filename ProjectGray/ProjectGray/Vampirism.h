//
//  Vampirism.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Vampirism_h
#define ProjectGray_Vampirism_h
#import "PowerUp.h"

@interface Vampirism : PowerUp

- (id) initPowerUpForUnit:(Unit*)unit;
- (void) applyPowerUp;
- (void) endPowerUp;

@end

#endif
