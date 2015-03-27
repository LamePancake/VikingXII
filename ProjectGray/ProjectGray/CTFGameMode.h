//
//  CTFGameMode.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_CTFGameMode_h
#define ProjectGray_CTFGameMode_h

#import "Game.h"
#import "EnvironmentEntity.h"

@interface CTFGameMode : Game

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile;

-(int)checkForWin;

- (NSMutableArray*) generateEnvironment;

@end

#endif
