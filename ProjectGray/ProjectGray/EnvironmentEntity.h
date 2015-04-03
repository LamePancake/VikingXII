//
//  EnvironmentEntity.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-27.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_EnvironmentEntity_h
#define ProjectGray_EnvironmentEntity_h

#import <Foundation/Foundation.h>
#import "EnvironmentStats.h"
#import "GLKit/GLKit.h"
#import "GameObject.h"
#import "Hex.h"
#import "PowerUp.h"

@interface EnvironmentEntity : NSObject <GameObject>

@property (nonatomic) Hex* hex;
@property (nonatomic) EnvironmentClasses type;
@property (nonatomic) float percentSearched;
@property PowerUp* powerUp;

-(instancetype) initWithType: (EnvironmentClasses) type atPosition:(GLKVector3)pos withRotation:(GLKVector3)rot andScale: (GLKVector3)scl onHex:(Hex*)hex;

@end

#endif
