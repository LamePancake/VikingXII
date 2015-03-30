//
//  UnitActions.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "Unit.h"
#import "Hex.h"
#import "HexCells.h"
#import "Task.h"
#import "MovementTask.h"
#import "RotationTask.h"
#import "EnvironmentEntity.h"

static NSString *attackInfo;

@class Game;

//Anything that gets passed to APSystem should already be "legal"
//
@interface UnitActions : NSObject
{
}

-(instancetype)initWithGame: (Game*)game;

/**
 * Moves a unit to the specified hex cell.
 * @param mover The unit being moved.
 * @param hex   The hex cell to which the unit will move.
 * @param map   The map on which the unit will move.
 */
- (id<Task>)moveThis:(Unit *)mover toHex:(Hex *)hex onMap:(HexCells *)map; //GameObjectMovement

/**
 * Calculates the damage done on the target based on the attackers 
 * stats/state and decrements it from the targets health.
 * @param attacker is the unit who's currently attacking the target
 * @param target is the unit being attacked by the attacker
 */
-(void)attackThis:(Unit*)target with:(Unit*)attacker;

/**
 * Makes the given asteroid invisible and removes it from the list of EnvironmentEnity objects.
 * @param asteroid The asteroid to be destroyed.
 * @param attacker The attacker destroying the asteroid.
 */
-(void)destroyAsteroid:(EnvironmentEntity*)asteroid with:(Unit*)attacker;

/**
 * Sets the given unit's action point pool back to the default value for that ship class and faction.
 * @param thisObject The unit to have its AP pool reset.
 */
-(void)refillAPFor:(Unit*)thisObject;//This should be called at beginning of turn for all GameObjects

/**
 * Heals the target unit using the given healer unit.
 * @param target The unit being healed.
 * @param healer The unit performing the healing.
 */
-(void)healThis:(Unit*)target byThis:(Unit*)healer;

/**
 * Searches a given environment entity for the flag.
 *
 * @param target         The target environment entity to search.
 * @param searcher       The unit searching the entity.
 * @param vikingAsteroid The asteroid containing the vikings' flag.
 * @param graysAsteroid  The asteroid containing the grays' flag.
 */
-(BOOL)searchThis:(EnvironmentEntity*)target byThis:(Unit*)searcher forVikingFlagLocation: (EnvironmentEntity*) vikingAsteroid orGraysFlagLocation:(EnvironmentEntity*) graysAsteroid;

/**
 * Displays the target unit's stats.
 * @param target  The unit whose stats should be displayed.
 * @param scouter The unit performing the scouting.
 */
-(Unit*)scoutThis:(Unit*)target with:(Unit*)scouter;

/**
 * Gets the last movement path determined in moveThis.
 * @return The most recent movement path.
 */
-(NSMutableArray*)getCurrentPath;

/**
 * Gets the attack information for the most recent attack.
 * @return The attack information for the most recent attack.
 */
-(NSString*) getAttackInfo;

/**
 * Sets the attack information.
 * @param info The new attack information string to store.
 */
-(void) setAttackInfo:(NSString*)info;
@end