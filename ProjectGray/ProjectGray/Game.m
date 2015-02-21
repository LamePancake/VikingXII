//
//  Game.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface Game ()

@end

@implementation Game

-(instancetype) initWithMode: (id<GameMode>)mode andPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map {
    if(self = [super init]) {
        _p1Units = p1Units;
        _p2Units = p2Units;
        
        _p1Faction = ((Unit *)[p1Units firstObject]).faction;
        _p2Faction = ((Unit *)[p2Units firstObject]).faction;
        
        _mode = mode;
        _selectedUnit = nil;
        _map = map;
    }
    
    return self;
}

-(Unit *) getUnitOnHex: (Hex *)hex forFaction: (Faction) faction {
    
    NSMutableArray* units = faction == _p1Faction ? _p1Units : _p2Units;
    
    for(Unit* aUnit in units) {
        if(hex == aUnit.hex) return aUnit;
    }
    
    return nil;
}

-(void) updateLegalActionsForUnit:(Unit *)unit {
    if(!unit) return;
    
    NSMutableArray* attackable = [_map movableRange:unit.attRange from:unit.hex];
    NSUInteger numAttackable = [attackable count];
    Faction enemyFaction = unit.faction == ALIENS ? VIKINGS : ALIENS;
    
    // Filter out any hex tiles with no enemy units from the attackable array
    for(NSUInteger i = 0; i < numAttackable; i++) {
        if(![self getUnitOnHex:attackable[i] forFaction:enemyFaction]) [attackable removeObjectAtIndex:i];
    }
        
    [unit.movableHex addObjectsFromArray:[_map movableRange:unit.moveRange from:unit.hex]];
    [unit.attackableHex addObjectsFromArray:attackable];
}

-(void)selectTile:(Hex *)tile {
    /*
     Model does the following:
     
     Is there a unit selected?
     If so, did the player select the same cell as the one occupied by the currently selected unit?
     If so, set the current selection to nil and tell the controller that the unit was unselected.
     
     If not, is there an enemy unit in that cell?
     If so, can the currently selected unit attack that unit?
     If so,
     Do the damage calculations,
     Apply them to the other unit,
     Adjust remaining action points for the unit,
     Tell the controller that this all happened.
     If not, tell the controller that the player tried to do an invalid attack.
     
     Is there a friendly unit in that cell?
     If so,
     Set that unit to be the currently selected unit
     Call Determine Actions for Unit and return the result to the controller.
     
     If not, can the currently selected unit move to that cell?
     If yes, move the unit to that cell, subtract the appropriate number of action points, and tell the controller about the movement.
     If not, tell the controller that the player tried to do an invalid move to that cell.
     
     
     Function Determine Actions for Unit
     Determine possible movement paths using unit's speed
     */
    
    Unit* onTile = [self getUnitOnHex:tile forFaction:_whoseTurn];
    
    if(_selectedUnit)
    {
        // If they tapped the tile that the selected unit was on, unselected it
        if(_selectedUnit == onTile)
        {
            _selectedUnit = nil;
        }
        // Attack the enemy if possible
        else if(onTile.faction != _selectedUnit.faction && [_selectedUnit.attackableHex containsObject:tile])
        {
            // Unit actions attack enemy
        }
        // Move to another tile
        else if(!onTile && [_selectedUnit.movableHex containsObject:tile])
        {
            // Unit actions move
            _selectedUnit.hex = tile;
            _selectedUnit.position = GLKVector3Make(tile.worldPosition.x, tile.worldPosition.y, 0);
        }
    }

    // If they selected a tile with a friendly unit, set the current selection to that
    if(onTile.faction == _selectedUnit.faction)
    {
        _selectedUnit = onTile;
    }
    
    [self updateLegalActionsForUnit: _selectedUnit];
}
@end