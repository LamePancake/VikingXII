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
@property (nonatomic) int selectionSwitchCount;

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
        _selectedUnit = p1Units[0];
        _map = map;
        _taskManager = [[TaskManager alloc] init];
        _game = self;
        _currentRound = 1;
        _state = SELECTION;
        _selectionSwitchCount = 0;
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

-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange;
{
    if (!tile) return;
    
    NSMutableArray *range = _whoseTurn == _p1Faction ? vikingRange : alienRange;
    
    Unit* unitOnTile = [self getUnitOnHex:tile];
    if(unitOnTile == nil)
    {
        for(Hex* h in range)
        {
            if(h.q == tile.q && h.r == tile.r)
            {
                _selectedUnit.hex = tile;
                _selectedUnit.position = GLKVector3Make(tile.worldPosition.x, tile.worldPosition.y, UNIT_HEIGHT);
                break;
            }
        }
        
        NSMutableArray *units = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
        for(Unit* u in units)
        {
            if(u.hex == nil)
            {
                _selectedUnit = u;
                break;
            }
        }
    }
    else
    {
        if(unitOnTile.faction == _whoseTurn)
            _selectedUnit = unitOnTile;
    }
}

-(void)selectTile:(Hex *)tile
{
    if (!tile) return;

    Unit* unitOnTile = [self getUnitOnHex:tile];
    if(unitOnTile != nil && !unitOnTile.active)
    {
        NSLog(@"Unit is dead!");
        return;
    }
    
    if(_selectedUnit && _selectedUnit.taskAvailable)
    {
        // If they tapped the tile that the selected unit was on, unselect it
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

-(void)switchTurn
{
    if(_state == SELECTION)
    {
        [self switchTurnSelecting];
    }
    else
    {
        [self switchTurnPlaying];
    }
}

-(void)switchTurnSelecting
{
    _selectedUnit = nil;
    
    NSMutableArray *units = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
    for(int i = 0; i < units.count; i++)
    {
        if(((Unit*)units[i]).hex == nil)
        {
            NSLog(@"You still have units to place!");
            return;
        }
    }
    
    _whoseTurn = _whoseTurn == _p1Faction ? _p2Faction : _p1Faction;
    _selectionSwitchCount++;
    if(_selectionSwitchCount >= 2)
    {
        _state = PLAYING;
    }
}

-(void)switchTurnPlaying
{
    // Determine whose turn it should be
    _whoseTurn = _whoseTurn == _p1Faction ? _p2Faction : _p1Faction;
    _selectedUnit = nil;

    NSMutableArray* unitList;
    // Reset the action points of the faction who just finished their turn
    unitList = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
    
    for (Unit *unit in unitList)
    {
        [unit resetAP];
    }
}

-(int)checkForWin
{
    return [_mode checkForWinWithPlayerOneUnits:_p1Units andPlayerTwoUnits:_p2Units];
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