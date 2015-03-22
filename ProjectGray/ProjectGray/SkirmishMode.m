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
    return [super init];
}


//TODO: Change returned value to a faction instead
-(int) checkForWinWithPlayerOneUnits: (NSMutableArray *)p1Units andPlayerTwoUnits:(NSMutableArray *)p2Units
{
    BOOL playerOneAlive = NO;
    for(int i = 0; i < p1Units.count; i++)
    {
        if(((Unit*)p1Units[i]).active)
        {
            playerOneAlive = YES;
            break;
        }
    }
    
    BOOL playerTwoAlive = NO;
    for(int i = 0; i < p2Units.count; i++)
    {
        if(((Unit*)p2Units[i]).active)
        {
            playerTwoAlive = YES;
            break;
        }
    }
    
    if(playerOneAlive && playerTwoAlive)
        return -1;
    else if(playerOneAlive && playerTwoAlive)
        return ((Unit*)p1Units[0]).faction;
    else if(playerOneAlive && playerTwoAlive)
        return ((Unit*)p2Units[0]).faction;
    return -1;
}

+ (NSString *)getName
{
    return @"Skirmish";
}

@end
