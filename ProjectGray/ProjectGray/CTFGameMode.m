//
//  CTFGameMode.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFGameMode.h"

@interface CTFGameMode ()

@end

@implementation CTFGameMode

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile
{
    if (!tile) return;
    
    Unit* unitOnTile = [self getUnitOnHex:tile];
    
    if(unitOnTile != nil && !unitOnTile.active && self.selectedUnitAbility != HEAL)
    {
        NSLog(@"Unit is dead!");
        return;
    }
    
    if(self.selectedUnit && self.selectedUnit.taskAvailable)
    {
        // If they tapped the tile that the selected unit was on, unselect it
        if(self.selectedUnit == unitOnTile)
        {
            self.selectedUnit = nil;
        }
        // Attack the enemy if possible
        else if(self.selectedUnitAbility == ATTACK &&
                unitOnTile != nil &&
                unitOnTile.faction != self.selectedUnit.faction &&[HexCells distanceFrom:unitOnTile.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            [UnitActions attackThis:unitOnTile with:self.selectedUnit];
        }
        // Move to another tile
        else if(self.selectedUnitAbility == MOVE &&
                tile.hexType == EMPTY &&
                [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] <= self.selectedUnit.moveRange)
        {
            [UnitActions moveThis:self.selectedUnit toHex:tile onMap:self.map];
        }
        // Heal a member of your faction
        else if (self.selectedUnitAbility == HEAL &&
                 unitOnTile != nil &&
                 unitOnTile.faction == self.whoseTurn &&
                 [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            [UnitActions healThis:unitOnTile byThis:self.selectedUnit];
        }
        else if (self.selectedUnitAbility == SEARCH &&
                 tile.hexType == ASTEROID &&
                 [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] == 1)
        {
            EnvironmentEntity* entity = [self getEnvironmentEntityOnHex:tile];
            [UnitActions searchThis:entity byThis:self.selectedUnit];
        }
    }
    
    // If they selected a tile with a friendly unit, set the current selection to that
    if(self.selectedUnitAbility != HEAL && unitOnTile && unitOnTile.faction == self.whoseTurn)
    {
        self.selectedUnit = unitOnTile;
        self.selectedUnitAbility = MOVE;
    }
}

- (NSMutableArray*) generateEnvironment
{
    NSMutableArray* environment = [[NSMutableArray alloc] init];
    
    Hex* hex = [self.map hexAtQ:0 andR:0];
    
    EnvironmentEntity *entity = [[EnvironmentEntity alloc] initWithType: ENV_ASTEROID atPosition:GLKVector3Make(0, 0, 0.1) withRotation:GLKVector3Make(0, 0, 0) andScale:GLKVector3Make(0.005, 0.005, 0.005) onHex:hex];
    
    [environment addObject:entity];
    
    return environment;
}

-(int)checkForWin
{
    return -1;
}

@end