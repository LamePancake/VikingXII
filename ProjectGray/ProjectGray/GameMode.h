//
//  GameMode.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_GameMode_h
#define ProjectGray_GameMode_h
#import "Unit.h"

/**
 * @brief The base interface for all game modes.
 * @discussion The GameMode encapsulates information specific to a game mode (name, time limit,
 * win condition, other game state information).
 */
@protocol GameMode

/**
 * The mode's name.
 */
@property(strong, nonatomic) NSString *name;

/**
 * Checks whether the win condition for the mode has been satisfied.
 *
 * @param playerOne The array of player one's units.
 * @param playerTwo The array of player two's units.
 * @return 0 if neither player has one, or the wining player (1 or 2).
 */
- (int) checkForWinWithPlayerOneUnits: (NSMutableArray*)p1Units andPlayerTwoUnits: (NSMutableArray*)p2Units;

@end

#endif
