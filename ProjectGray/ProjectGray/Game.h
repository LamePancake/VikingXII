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

@interface Game : NSObject

/// The list of hex cells composing the map.
@property (strong, nonatomic) HexCells* map;

/// An array of Unit objects belonging to player 1.
@property (strong, nonatomic) NSMutableArray* p1Units;
/// An array of Unit objects belonging to player 2.
@property (strong, nonatomic) NSMutableArray* p2Units;

/// Player 1's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p1Faction;
/// Player 2's faction (ALIENS or VIKINGS).
@property (nonatomic) Faction p2Faction;

/// The faction who has the current turn.
@property (readonly, nonatomic) Faction whoseTurn;

/// The game mode object determining the win condition, etc.
@property (strong, nonatomic) id<GameMode> mode;

/// The currently selected unit, if any.
@property (weak, nonatomic) Unit* selectedUnit;

-(instancetype) initWithMode: (id<GameMode>)mode andPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map;

-(Game*) initWithSize:(int)size;

-(void) gameUpdate;
/**
 * Gets the unit on the specified hex cell, if there is one.
 *
 * @param hex The hex cell to check.
 * @return The unit for @a player on @a hex if there is one or nil.
 */
-(Unit *)getUnitOnHex: (Hex *)hex;

/**
 * @brief Given the specified unit, gets the legal attacks and moves and stores them in the provided arrays.
 * @discussion The attacks and moves arrays will have their contents over-written with a list of Hex*'s.
 *             The legal attacks and moves take into account the movement's attack range, movement range, and
 *             any intervening obstacles.
 *
 * @param unit    The unit for which to find the legal actions.
 * @param attacks The array in which to store legal attacks.
 * @param moves   The array in which to store legal moves.
 */
-(void)updateLegalActionsForUnit:(Unit*)unit;

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile;
-(void) showActionsForSelected;
@end