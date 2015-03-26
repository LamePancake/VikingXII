//
//  Settings.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Settings_h
#define ProjectGray_Settings_h
#import "GameMode.h"

@interface Settings : NSObject

/// The currently selected game mode.
@property(nonatomic) int currentMode;

/// The list of all game modes.
@property (strong, readonly, nonatomic) NSArray* modes;

@property (nonatomic) int mapSize;

/// Switches the current mode to the next mode in the list.
-(void)switchToNextMode;

/// Switches the current mode to the previous mode in the list.
-(void)switchToPrevMode;

/// Get the name of the currently selected game mode.
-(NSString*)getModeName;

@end


#endif
