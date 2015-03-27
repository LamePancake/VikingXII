//
//  SkirmishGameMode.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkirmishGameMode.h"

@interface SkirmishGameMode ()

@end

@implementation SkirmishGameMode

-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange;
{
    if (!tile) return;
    
    NSMutableArray *range = self.whoseTurn == self.p1Faction ? vikingRange : alienRange;
    
    Unit* unitOnTile = [self getUnitOnHex:tile];
    if(unitOnTile == nil)
    {
        for(Hex* h in range)
        {
            if(h.q == tile.q && h.r == tile.r)
            {
                self.selectedUnit.hex.hexType = EMPTY;
                if (self.selectedUnit.faction == VIKINGS)
                {
                    tile.hexType = VIKING;
                }
                else if (self.selectedUnit.faction == ALIENS)
                {
                    tile.hexType = ALIEN;
                }
                self.selectedUnit.hex = tile;
                self.selectedUnit.position = GLKVector3Make(tile.worldPosition.x, tile.worldPosition.y, UNIT_HEIGHT);
                break;
            }
        }
        
        NSMutableArray *units = self.whoseTurn == self.p1Faction ? self.p1Units : self.p2Units;
        for(Unit* u in units)
        {
            if(u.hex == nil)
            {
                self.selectedUnit = u;
                break;
            }
        }
    }
    else
    {
        if(unitOnTile.faction == self.whoseTurn)
            self.selectedUnit = unitOnTile;
    }
}

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