//
//  SkirmishGameMode.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkirmishGameMode.h"
#import "EnvironmentEntity.h"

@interface SkirmishGameMode ()

@end

@implementation SkirmishGameMode

-(void)selectTile:(Hex *)tile
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
        // Scout the enemy if possible
        else if(self.selectedUnitAbility == SCOUT &&
                unitOnTile != nil &&
                unitOnTile.faction != self.selectedUnit.faction &&[HexCells distanceFrom:unitOnTile.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            //[UnitActions attackThis:unitOnTile with:self.selectedUnit];
        }
        // Move to another tile
        else if(self.selectedUnitAbility == MOVE &&
                !unitOnTile &&
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
    }
    
    // If they selected a tile with a friendly unit, set the current selection to that
    if(self.selectedUnitAbility != HEAL && unitOnTile && unitOnTile.faction == self.whoseTurn)
    {
        self.selectedUnit = unitOnTile;
        self.selectedUnitAbility = MOVE;
    }
}

-(int)checkForWin
{
    return [self checkForWinWithPlayerOneUnits:self.p1Units andPlayerTwoUnits:self.p2Units];
}

- (NSMutableArray*) generateEnvironment
{
    NSMutableArray* environment = [[NSMutableArray alloc] init];
    
    return environment;
}

-(int) checkForWinWithPlayerOneUnits: (NSMutableArray *)p1Units andPlayerTwoUnits:(NSMutableArray *)p2Units
{
    BOOL playerOneAlive = NO;
    for(int i = 0; i < p1Units.count; i++)
    {
        if(((Unit*)p1Units[i]).active)
        {
            playerOneAlive = YES;
            break;
        }
    }
    
    BOOL playerTwoAlive = NO;
    for(int i = 0; i < p2Units.count; i++)
    {
        if(((Unit*)p2Units[i]).active)
        {
            playerTwoAlive = YES;
            break;
        }
    }
    
    if(playerOneAlive && playerTwoAlive)
        return -1;
    else if(playerOneAlive && playerTwoAlive)
        return ((Unit*)p1Units[0]).faction;
    else if(playerOneAlive && playerTwoAlive)
        return ((Unit*)p2Units[0]).faction;
    return -1;
}



@end