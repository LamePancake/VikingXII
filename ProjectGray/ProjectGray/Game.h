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

@interface Game : NSObject

@property (nonatomic) HexCells* map;
@property (nonatomic) NSMutableArray* p1Units;
@property (nonatomic) NSMutableArray* p2Units;
@property (nonatomic) Faction p1Faction;
@property (nonatomic) Faction p2Faction;
@property (nonatomic) Unit* selectedUnit;

-(Game*) initWithSize:(int)size;

/**
 * Gets the unit on the specified hex cell for the given player, if there is one.
 *
 * @param hex    The hex cell to check.
 * @param player The player whose units are to be searched.
 * @return The unit for @a player on @a hex if there is one or nil.
 */
-(Unit *)getUnitOnHex: (Hex *)hex forFaction: (Faction)faction;

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
@end