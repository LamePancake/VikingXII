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
#import "Item.h"

typedef enum FlagState
{
    HIDDEN,
    DROPPED,
    TAKEN,
} FlagState;

@interface CTFGameMode : Game

@property EnvironmentEntity* vikingFlagHidingLocation;
@property EnvironmentEntity* graysFlagHidingLocation;
@property FlagState vikingFlagState;
@property FlagState graysFlagState;
@property Item* vikingFlag;
@property Item* graysFlag;
@property Unit* vikingFlagCarrier;
@property Unit* graysFlagCarrier;
//@property FlagState vikingFlagState;

-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange;

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile;

-(int)checkForFlagCaptureInVikingZone: (NSMutableArray*)vikingCaptureZone andGraysZone: (NSMutableArray*)grayCaptureZone;

-(void)update;

- (NSMutableArray*) generateEnvironment;

-(void)addToRespawnList: (Unit*)units from: (Faction*)whoseturn;

@end

#endif
