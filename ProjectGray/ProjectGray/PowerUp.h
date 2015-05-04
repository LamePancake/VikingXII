//
//  PowerUp.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-04-02.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_PowerUp_h
#define ProjectGray_PowerUp_h
#import "Unit.h"

typedef enum PowerUpType
{
    ACTION_HERO,
    LUCKY_CHARM,
    VAMPIRISM,
    KABLAM,
    NOPOWERUP
} PowerUpType;

@interface PowerUp : NSObject

@property (weak, nonatomic) Unit* affectedUnit;
@property int numOfRounds;
- (instancetype) initPowerUpForUnit:(Unit*)unit forThisManyRounds:(int)num;
- (void) applyPowerUp;
- (void) endPowerUp;

@end

#endif
