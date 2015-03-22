//
//  GameObject.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"

@protocol GameObject

@property (nonatomic) GLKVector3 rotation;

@property (nonatomic) GLKVector3 position;

@property (nonatomic) float scale;
//If this object is available for a task
@property (nonatomic) BOOL taskAvailable;

@end
