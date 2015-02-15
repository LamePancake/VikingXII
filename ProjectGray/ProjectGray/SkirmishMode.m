//
//  SkirmishMode.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "SkirmishMode.h"

@implementation SkirmishMode

- (instancetype) init {
    self = [super init];
    
    if(!self)
        return nil;
    
    [self setName: @"Skirmish"];
    return self;
}

@end
