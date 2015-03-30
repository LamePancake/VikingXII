//
//  Game.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "HexCells.h"
#import "Unit.h"
#import "EnvironmentEntity.h"
#import "GameMode.h"
#import "TaskManager.h"
#import "UnitActions.h"
#include "NSMutableArray_Shuffling.h"

// Have to forward declare these to avoid circular includes
@class GameViewController;
@class UnitActions;

typedef enum _GameState {
    SELECTION = 0,
    FLAG_PLACEMENT = 1,
    PLAYING = 2
} GameState;

typedef enum UnitAbilities
{
    ATTACK,
    MOVE,
    HEAL,
    SEARCH,
    SCOUT,
    NONE
} UnitAbilities;

@interface Game : NSObject

@property GameMode mode;

// The current state of the game
@property (nonatomic) int state;

/// The list of hex cells composing the map.
@property (strong, nonatomic) HexCells* map;

/// An array of Unit objects belonging to player 1.
@property (strong, nonatomic) NSMutableArray* p1Units;
/// An array of Unit objects belonging to player 2.
@property (strong, nonatomic) NSMutableArray* p2Units;
/// An array of Units queueing for respawn
@property (strong, nonatomic) NSMutableArray* p1RespawnUnits;
/// An array of Units queueing for respawn
@property (strong, nonatomic) NSMutableArray* p2RespawnUnits;
// An array of environment entities (e.g. asteroids)
@property (strong, nonatomic) NSMutableArray* environmentEntities;
@property (nonatomic) int selectionSwitchCount;
/// Reference to the GameViewController coordinating with this game.
@property (weak, nonatomic, readonly) GameViewController* gameVC;

/// Player 1's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p1Faction;
/// Player 2's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p2Faction;

/// The faction who has the current turn.
@property (nonatomic) Faction whoseTurn;

@property (strong, nonatomic, readonly) TaskManager* taskManager;
@property (strong, nonatomic, readonly) UnitActions* actions;

@property (nonatomic) int currentRound;

/// The currently selected unit, if any.
@property (weak, nonatomic) Unit* selectedUnit;

// The currently scouted unit
@property (weak, nonatomic) Unit* selectedScoutedUnit;

@property (nonatomic) UnitAbilities selectedUnitAbility;

-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map
                   andGameVC: (GameViewController*)gameVC;

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

-(void)switchTurnSelecting;

-(void)switchTurnPlaying;

/**
 * Respawn the units
 */
-(void)respawnUnits;

-(void)update;

- (NSMutableArray*) generateEnvironment;

/**
 * Saves the scores of the players
 */
-(BOOL)saveScores;

/**
 * Method writes a string to a text file
 */
-(void) writeToTextFile;

/**
 * Method retrieves content from documents directory and displays it in an alert
 */
-(void) readTextFile;

/**
 * If there is a game running, gets the task manager instance associated with the game. Otherwise, returns nil.
 */
+(TaskManager *)taskManager;
@end