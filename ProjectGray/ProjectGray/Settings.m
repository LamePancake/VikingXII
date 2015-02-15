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

/// The list of all game modes.
@property NSArray* modes;

/// The array index of the currently selected mode.
@property int modeIdx;

@end

@implementation Settings

-(instancetype) init {
    self = [super init];
    
    if(self) {
        
        // Initialise the modes list and set the current mode
        _modes = @[ [[ConvoyMode alloc] init],
                    [[SkirmishMode alloc] init]];
        _modeIdx = 0;
        _currentMode = _modes[0];
    }
    
    return self;
}

-(void)switchToPrevMode {
    if(--_modeIdx == -1) _modeIdx = [_modes count] - 1;
    _currentMode = _modes[_modeIdx];
}

-(void)switchToNextMode {
    if(++_modeIdx == [_modes count]) _modeIdx = 0;
    _currentMode = _modes[_modeIdx];
}



@end