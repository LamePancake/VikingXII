//
//  SkirmishMode.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "SkirmishMode.h"

@interface SkirmishMode() {
    NSString *_name;
}
@end

@implementation SkirmishMode

@synthesize name = _name;

- (instancetype) init {
    self = [super init];
    
    if(!self)
        return nil;
    
    _name = @"Skirmish";
    return self;
}

-(int) checkForWinWithPlayerOneUnits: (NSMutableArray *)p1Units andPlayerTwoUnits:(NSMutableArray *)p2Units {
    return 0;
}

@end
