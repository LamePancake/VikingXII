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

-(Game*) initWithSize:(int)size{
    _map = [[HexCells alloc]initWithSize:size];
    return self;
}

-(void) gameUpdate {
    [self showActionsForSelected];
}

-(void) showActionsForSelected {
    [self updateLegalActionsForUnit:_selectedUnit];
    for (Hex *currentHex in _selectedUnit.movableHex) {
        [currentHex setColour:GLKVector4Make(255.0f, 255.0f, 0.0f, 1.0f)];
    }
    for (Hex *currentHex in _selectedUnit.attackableHex) {
        [currentHex setColour:GLKVector4Make(0.0f, 255.0f, 0.0f, 1.0f)];
    }
}

-(Unit *) getUnitOnHex: (Hex *)hex {
    
    // Search both sets of units
    for(Unit* aUnit in _p1Units) {
        if(hex == aUnit.hex) return aUnit;
    }
    for(Unit* aUnit in _p2Units) {
        if(hex == aUnit.hex) return aUnit;
    }
    
    return nil;
}

-(void) updateLegalActionsForUnit:(Unit *)unit {
    if(!unit) return;
    
    NSMutableArray* attackable = [_map movableRange:unit.attRange from:unit.hex];
    NSMutableArray* movable = [_map movableRange:unit.moveRange from:unit.hex];
    NSUInteger numAttackable = [attackable count];
    NSUInteger numMovable = [movable count];
    
    Faction enemyFaction = unit.faction == ALIENS ? VIKINGS : ALIENS;
    
    // Filter out any hex tiles with no enemy units from the attackable array
    for(NSUInteger i = 0; i < numAttackable; i++) {
        Unit* unit = [self getUnitOnHex:attackable[i]];
        
        if(!unit || !(unit.faction == enemyFaction))
            [attackable removeObjectAtIndex:i];
    }
    
    // Filter out any tiles with obstacles in the movable array
    for(NSUInteger i = 0; i < numMovable; i++) {
        Unit* unit = [self getUnitOnHex:attackable[i]];
        
        if(!unit) [movable removeObjectAtIndex:i];
    }
    
    [unit.movableHex addObjectsFromArray: movable];
    [unit.attackableHex addObjectsFromArray:attackable];
}

-(void)selectTile:(Hex *)tile {
    if (!tile) return;

    Unit* onTile = [self getUnitOnHex:tile];
    //NSLog(@"Selected unit's faction: %@", (onTile.faction == ))
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
    if(onTile.faction == _whoseTurn)
    {
        _selectedUnit = onTile;
    }
    
    [self updateLegalActionsForUnit: _selectedUnit];
}
@end