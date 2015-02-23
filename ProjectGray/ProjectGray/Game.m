//
//  Game.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "SkirmishMode.h"
#import "TaskManager.h"
#import "MovementTask.h"

@interface Game ()
{
    TaskManager *_taskManager;
}

@end

@implementation Game

-(instancetype) initFull {
    _map = [[HexCells alloc] initWithSize:5];
    NSMutableArray* vikingUnits;
    for(int i = 0; i < 3; ++i) {
        [vikingUnits addObject:[[Unit alloc] initShipWithFaction:VIKINGS andShipClass:LIGHT andHex:[_map hexAtQ:i andR:0]]];
    }
    _p1Units = vikingUnits;
    NSMutableArray* alienUnits;
    for(int i = 0; i < 3; ++i) {
        [alienUnits addObject:[[Unit alloc] initShipWithFaction:ALIENS andShipClass:LIGHT andHex:[_map hexAtQ:0 andR:i]]];
    }
    _p2Units = alienUnits;
    _p1Faction = VIKINGS;
    _p2Faction = ALIENS;
    _mode = [[SkirmishMode alloc] init];
    _selectedUnit = nil;
    _taskManager = [[TaskManager alloc] init];
    return self;
}

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

-(void)selectTile:(Hex *)tile {
    if (!tile) return;

    Unit* onTile = [self getUnitOnHex:tile];
    if(_selectedUnit)
    {
        // If they tapped the tile that the selected unit was on, unselected it
        if(_selectedUnit == onTile)
        {
            _selectedUnit = nil;
        }
        // Attack the enemy if possible
        else if(onTile.faction != _selectedUnit.faction && [HexCells distanceFrom:onTile.hex toHex:_selectedUnit.hex])
        {
            [UnitActions attackThis:onTile with:_selectedUnit];
        }
        // Move to another tile
        else if(!onTile && [HexCells distanceFrom:tile toHex:_selectedUnit.hex] <= _selectedUnit.moveRange)
        {
            // Unit actions move
            //_selectedUnit.hex = tile;
            //_selectedUnit.position = GLKVector3Make(tile.worldPosition.x, tile.worldPosition.y, 0.02);
            NSMutableArray *path = [_map makePathFrom:_selectedUnit.hex.q :_selectedUnit.hex.r To:tile.q :tile.r];
            
            MovementTask *prevMovement = nil;
            Hex *prevHex = nil;
            for (Hex* cell in path)
            {
                MovementTask *moveTask;
                if (prevMovement && prevHex)
                {
                    moveTask = [[MovementTask alloc] initWithUnit:_selectedUnit fromInitial:prevHex toDestination:cell andNextTask:prevMovement];
                }
                else
                {
                    moveTask = [[MovementTask alloc] initWithUnit:_selectedUnit fromInitial:_selectedUnit.hex toDestination:cell andNextTask:nil];
                }
                prevMovement = moveTask;
                prevHex = cell;
                [_taskManager addTask:moveTask];
            }
        }
    }

    // If they selected a tile with a friendly unit, set the current selection to that
    if(onTile && onTile.faction == _whoseTurn)
    {
        _selectedUnit = onTile;
    }
}
@end