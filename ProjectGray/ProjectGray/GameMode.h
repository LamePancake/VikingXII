//
//  GameMode.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_GameMode_h
#define ProjectGray_GameMode_h
#import <Foundation/Foundation.h>

/**
 * @brief The base interface for all game modes.
 * @discussion The GameMode is an abstract class encapsulating all the relevant information about
 * a given game mode (name, time limit, win condition, other game state information).
 */
@interface GameMode : NSObject

/**
 * @brief The mode's name.
 */
@property(strong, nonatomic) NSString *name;

@end

#endif
