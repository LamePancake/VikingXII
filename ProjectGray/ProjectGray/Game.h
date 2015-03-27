//
//  Game.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "HexCells.h"
#import "Unit.h"
#import "UnitActions.h"
#include "GameMode.h"
#import "TaskManager.h"

typedef enum _GameState {
    SELECTION = 0,
    PLAYING = 1
} GameState;

typedef enum UnitAbilities
{
    ATTACK,
    MOVE,
    HEAL,
    SEARCH,
    NONE
} UnitAbilities;

@interface Game : NSObject

// The current state of the game
@property (nonatomic) int state;

/// The list of hex cells composing the map.
@property (strong, nonatomic) HexCells* map;

/// An array of Unit objects belonging to player 1.
@property (strong, nonatomic) NSMutableArray* p1Units;
/// An array of Unit objects belonging to player 2.
@property (strong, nonatomic) NSMutableArray* p2Units;
// An array of environment entities (e.g. asteroids)
@property (strong, nonatomic) NSMutableArray* environmentEntities;

/// Player 1's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p1Faction;
/// Player 2's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p2Faction;

/// The faction who has the current turn.
@property (readonly, nonatomic) Faction whoseTurn;

@property (nonatomic) int currentRound;

/// The currently selected unit, if any.
@property (weak, nonatomic) Unit* selectedUnit;

@property (nonatomic) UnitAbilities selectedUnitAbility;

-(instancetype) initWithPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map;

/**
 * Gets the unit on the specified hex cell, if there is one.
 *
 * @param hex The hex cell to check.
 * @return The unit for @a player on @a hex if there is one or nil.
 */
-(Unit *)getUnitOnHex: (Hex *)hex;

-(EnvironmentEntity *) getEnvironmentEntityOnHex: (Hex *)hex;

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 * @param alienRange a range of hex cells that can be selected by the aliens.
 * @param vikingRange a range of hex cells that can be selected by the vikings.
 */
-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange;

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile;

/**
 * Switches the turn to the other player.
 */
-(void)switchTurn;

/**
 * Checks to see if a faction won.
 */
-(int)checkForWin;

- (NSMutableArray*) generateEnvironment;

/**
 * If there is a game running, gets the task manager instance associated with the game. Otherwise, returns nil.
 */
+(TaskManager *)taskManager;
@end