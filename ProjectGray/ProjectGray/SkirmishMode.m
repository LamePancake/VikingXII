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

-(int) checkForWinWithPlayerOneUnits: (NSMutableArray *)p1Units andPlayerTwoUnits:(NSMutableArray *)p2Units
{
    int vikingsAlive = 0;
    for(int i = 0; i < p1Units.count; i++)
    {
        if(((Unit*)p1Units[i]).active)
        {
            vikingsAlive++;
            break;
        }
    }
    
    int graysAlive = 0;
    for(int i = 0; i < p2Units.count; i++)
    {
        if(((Unit*)p2Units[i]).active)
        {
            graysAlive++;
            break;
        }
    }
    
    if(vikingsAlive != 0 && graysAlive != 0)
        return 0;
    else if(vikingsAlive != 0 && graysAlive == 0)
        return 1;
    else if(vikingsAlive == 0 && graysAlive != 0)
        return 2;
    return 0;
}

@end
