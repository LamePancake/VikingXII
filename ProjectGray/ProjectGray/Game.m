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

static Game* _game = nil;

@interface Game ()

@property (strong, nonatomic) TaskManager* taskManager;
@property (strong, nonatomic) CADisplayLink* dispLink;

@end

@implementation Game
-(instancetype) initWithMode: (id<GameMode>)mode andPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map {
    if(_game) return nil;
    
    if((self = [super init])) {
        _p1Units = p1Units;
        _p2Units = p2Units;
        
        _p1Faction = ((Unit *)[p1Units firstObject]).faction;
        _p2Faction = ((Unit *)[p2Units firstObject]).faction;
        
        _mode = mode;
        _selectedUnit = nil;
        _map = map;
        _taskManager = [[TaskManager alloc] init];
        _game = self;
        _currentRound = 1;
    }
    return self;
}

-(void)dealloc {
    [_dispLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
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

    Unit* unitOnTile = [self getUnitOnHex:tile];
    if(unitOnTile != nil && !unitOnTile.active)
    {
        NSLog(@"Unit is dead!");
        return;
    }
    
    if(_selectedUnit)
    {
        // If they tapped the tile that the selected unit was on, unselected it
        if(_selectedUnit == unitOnTile)
        {
            _selectedUnit = nil;
        }
        // Attack the enemy if possible
        else if(unitOnTile != nil && unitOnTile.faction != _selectedUnit.faction && [HexCells distanceFrom:unitOnTile.hex toHex:_selectedUnit.hex] <= _selectedUnit.stats->attackRange)
        {
            [UnitActions attackThis:unitOnTile with:_selectedUnit];
        }
        // Move to another tile
        else if(!unitOnTile && [HexCells distanceFrom:tile toHex:_selectedUnit.hex] <= _selectedUnit.moveRange)
        {
            // Unit actions move
            [UnitActions moveThis:_selectedUnit toHex:tile onMap:_map];
        }
    }

    // If they selected a tile with a friendly unit, set the current selection to that
    if(unitOnTile && unitOnTile.faction == _whoseTurn)
    {
        _selectedUnit = unitOnTile;
    }
}

-(void)switchTurn {
    _whoseTurn = _whoseTurn == _p1Faction ? _p2Faction : _p1Faction;
    _selectedUnit = nil;
    
    if (_whoseTurn == _p2Faction)
    {
        for (Unit *unit in _p2Units)
        {
            [unit resetAP];
        }
    }
    else
    {
        for (Unit *unit in _p1Units)
        {
            [unit resetAP];
        }
    }
}

-(int)checkForWin
{
    return [_mode checkForWinWithPlayerOneUnits: _p1Units andPlayerTwoUnits:_p2Units];
}

+(TaskManager *) taskManager {
    return _game ? _game.taskManager : nil;
}

-(void) gameUpdate {
    return;
}

-(void) endRound {
    for(Unit* currentUnit in _p1Units) {
        [currentUnit resetAP];
    }
    for(Unit* currentUnit in _p2Units) {
        [currentUnit resetAP];
    }
    ++_currentRound;
}

@end