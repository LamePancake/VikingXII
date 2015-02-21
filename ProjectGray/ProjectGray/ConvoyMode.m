//
//  ConvoyMode.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConvoyMode.h"

@interface ConvoyMode() {
    NSString *_name;
}
@end

@implementation ConvoyMode

@synthesize name = _name;

-(instancetype) init {
    self = [super init];
    
    if(!self) {
        return nil;
    }
    
    _name = @"Convoy";
    
    return self;
}

@end