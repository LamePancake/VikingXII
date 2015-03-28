//
//  Game.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "TaskManager.h"
#import "MovementTask.h"

static Game* _game = nil;

@interface Game ()

@property (strong, nonatomic) TaskManager* taskManager;
@property (strong, nonatomic) CADisplayLink* dispLink;
@property (nonatomic) int selectionSwitchCount;

@end

@implementation Game
-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map
{
    if(_game) return nil;
    
    if((self = [super init]))
    {
        _mode = mode;
        _p1Units = p1Units;
        _p2Units = p2Units;
        _map = map;
        _p1Faction = ((Unit *)[p1Units firstObject]).faction;
        _p2Faction = ((Unit *)[p2Units firstObject]).faction;
        
        _selectedUnit = p1Units[0];
        _taskManager = [[TaskManager alloc] init];
        _game = self;
        _currentRound = 1;
        _state = SELECTION;
        _selectionSwitchCount = 0;
        _selectedUnitAbility = NONE;
        
        _environmentEntities = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableArray*) generateEnvironment
{
    NSMutableArray* environment = [[NSMutableArray alloc] init];
    
    return environment;
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

-(EnvironmentEntity *) getEnvironmentEntityOnHex: (Hex *)hex
{
    
    // Search both sets of units
    for(EnvironmentEntity* entity in _environmentEntities) {
        if(hex == entity.hex) return entity;
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
                _selectedUnit.hex.hexType = EMPTY;
                if (_selectedUnit.faction == VIKINGS)
                {
                    tile.hexType = VIKING;
                }
                else if (_selectedUnit.faction == ALIENS)
                {
                    tile.hexType = ALIEN;
                }
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

-(void)update
{
    
}

-(void)selectTile:(Hex *)tile
{
    if (!tile) return;

    Unit* unitOnTile = [self getUnitOnHex:tile];
    
    if(unitOnTile != nil && !unitOnTile.active && _selectedUnitAbility != HEAL)
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
        else if(_selectedUnitAbility == ATTACK &&
                unitOnTile != nil &&
                unitOnTile.faction != _selectedUnit.faction &&[HexCells distanceFrom:unitOnTile.hex toHex:_selectedUnit.hex] <= _selectedUnit.stats->attackRange)
        {
            [UnitActions attackThis:unitOnTile with:_selectedUnit];
        }
        // Move to another tile
        else if(_selectedUnitAbility == MOVE &&
                !unitOnTile &&
                [HexCells distanceFrom:tile toHex:_selectedUnit.hex] <= _selectedUnit.moveRange)
        {
            [UnitActions moveThis:_selectedUnit toHex:tile onMap:_map];
        }
        // Heal a member of your faction
        else if (_selectedUnitAbility == HEAL &&
                 unitOnTile != nil &&
                 unitOnTile.faction == _whoseTurn &&
                 [HexCells distanceFrom:tile toHex:_selectedUnit.hex] <= _selectedUnit.stats->attackRange)
        {
            [UnitActions healThis:unitOnTile byThis:_selectedUnit];
        }
        else if (_selectedUnitAbility == SEARCH &&
                 tile.hexType == ASTEROID &&
                 [HexCells distanceFrom:tile toHex:_selectedUnit.hex] == 1)
        {
            
        }
        else if (_selectedUnitAbility == SCOUT &&
                 unitOnTile != nil &&
                 unitOnTile.faction != _selectedUnit.faction &&[HexCells distanceFrom:unitOnTile.hex toHex:_selectedUnit.hex] <= _selectedUnit.stats->attackRange)
        {
            
        }
    }
    
    // If they selected a tile with a friendly unit, set the current selection to that
    if(_selectedUnitAbility != HEAL && unitOnTile && unitOnTile.faction == _whoseTurn)
    {
        _selectedUnit = unitOnTile;
        _selectedUnitAbility = MOVE;
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
    NSMutableArray *units = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
    for(int i = 0; i < units.count; i++)
    {
        if(((Unit*)units[i]).hex == nil)
        {
             _selectedUnit = units[i];
            NSLog(@"You still have units to place!");
            return;
        }
    }
    
    _whoseTurn = _whoseTurn == _p1Faction ? _p2Faction : _p1Faction;
    units = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
    _selectionSwitchCount++;
    _selectedUnit = units[0];
    if(_selectionSwitchCount >= 2)
    {
        _state = PLAYING;
        _selectedUnit = nil;
    }
}

-(void)switchTurnPlaying
{
    // Determine whose turn it should be
    _whoseTurn = _whoseTurn == _p1Faction ? _p2Faction : _p1Faction;
    _selectedUnit = nil;
    _selectedUnitAbility = NONE;

    NSMutableArray* unitList;
    // Reset the action points of the faction who just finished their turn
    unitList = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
    
    for (Unit *unit in unitList)
    {
        [unit resetAP];
    }
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