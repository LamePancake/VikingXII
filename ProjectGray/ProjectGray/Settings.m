//
//  Settings.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Settings.h"

@interface Settings()
@end

@implementation Settings

-(instancetype) init {
    self = [super init];
    
    if(self) {
        _currentMode = SKIRMISH;
        _mapSize = 8;
    }
    
    return self;
}

-(void)switchToPrevMode {
    if(--_currentMode == -1) _currentMode = NUMMODES - 1;
}

-(void)switchToNextMode {
    if(++_currentMode == NUMMODES) _currentMode = SKIRMISH;
}

-(NSString*)getModeName
{
    switch (_currentMode) {
        case SKIRMISH:
            return @"Skirmish";
            break;
        case CTF:
            return @"CTF";
            break;
        default:
            return @"Oops!";
            break;
    }
}

@end