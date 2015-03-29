//
//  SkirmishGameMode.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_SkirmishGameMode_h
#define ProjectGray_SkirmishGameMode_h

#import "Game.h"

@interface SkirmishGameMode : Game

-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map andGameVC:(GameViewController *)gameVC;

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile;

- (NSMutableArray*) generateEnvironment;

@end

#endif
