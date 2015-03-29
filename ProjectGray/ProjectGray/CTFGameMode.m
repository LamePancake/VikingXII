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

-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map
{
    if((self = [super initGameMode:mode withPlayer1Units:p1Units andPlayer2Units:p2Units andMap:map]))
    {
        _graysFlag = [[Item alloc]initWithFaction:VIKINGS andClass:FLAG atPosition:GLKVector3Make(0, 0, 0.05) withRotation:GLKVector3Make(0, 0, 0) andScale:GLKVector3Make(0.01, 0.01, 0.01) onHex:nil];
        _vikingFlag = [[Item alloc]initWithFaction:ALIENS andClass:FLAG atPosition:GLKVector3Make(0, 0, 0.05) withRotation:GLKVector3Make(0, 0, 0) andScale:GLKVector3Make(0.01, 0.01, 0.01) onHex:nil];
        
        self.environmentEntities = [self generateEnvironment];
    }
    
    return self;
}

-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange
{
    if (!tile) return;
    
    if (self.state == FLAG_PLACEMENT && tile.hexType == ASTEROID)
    {
        for (EnvironmentEntity* entity in self.environmentEntities) {
            if (entity.hex == tile) {
                
                if (self.whoseTurn == VIKINGS)
                {
                    _vikingFlagHidingLocation = entity;
                    _vikingFlag.position = entity.position;
                    _vikingFlagState = HIDDEN;
                    _vikingFlagCarrier = nil;
                }
                else
                {
                    _graysFlagHidingLocation = entity;
                    _graysFlag.position = entity.position;
                    _graysFlagState = HIDDEN;
                    _graysFlagCarrier = nil;
                }
            }
        }
    }
    else if (self.state == SELECTION)
    {
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
    
}

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
    
    if(unitOnTile != nil && !unitOnTile.active && self.selectedUnitAbility != HEAL && self.selectedUnitAbility != SEARCH)
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
        else if (self.selectedUnitAbility == ATTACK &&
                 self.selectedUnit.shipClass == HEAVY &&
                 tile.hexType == ASTEROID)
        {
            EnvironmentEntity* entity = [self getEnvironmentEntityOnHex:tile];
            
            if (entity.hex == tile && [HexCells distanceFrom:entity.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
            {
                [UnitActions destroyAsteroid:entity with:self.selectedUnit];
                
                if (entity.active == false)
                {
                    if (_vikingFlagHidingLocation == entity)
                    {
                        _vikingFlagState = DROPPED;
                        _vikingFlag.hex = entity.hex;
                        entity.hex.hexType = FLAG;
                    }
                    
                    if (_graysFlagHidingLocation == entity)
                    {
                        _graysFlagState = DROPPED;
                        _graysFlag.hex = entity.hex;
                        entity.hex.hexType = FLAG;
                    }
                }
            }
            
        }
        // Attack the enemy if possible
        else if(self.selectedUnitAbility == ATTACK &&
                unitOnTile != nil &&
                unitOnTile.faction != self.selectedUnit.faction && [HexCells distanceFrom:unitOnTile.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            [UnitActions attackThis:unitOnTile with:self.selectedUnit];
            [self addToRespawnList:unitOnTile];
        }
        // Move to another tile
        else if(self.selectedUnitAbility == MOVE &&
                tile.hexType == EMPTY &&
                [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] <= self.selectedUnit.moveRange)
        {
            /*if (tile.hexType == FLAG)
            {
                if (self.selectedUnit.faction == VIKINGS)
                {
                    if (tile == _graysFlag.hex && _graysFlagState == DROPPED) {
                        _graysFlagCarrier = self.selectedUnit;
                        _graysFlagState = TAKEN;
                        NSLog(@"Gray flag picked up!");
                    }
                    else if (tile == _vikingFlag.hex && _vikingFlagState == DROPPED) {
                        _vikingFlagCarrier = self.selectedUnit;
                        _vikingFlagState = TAKEN;
                        NSLog(@"Viking flag picked up!");
                    }
                }
                else
                {
                    if (tile == _vikingFlag.hex && _vikingFlagState == DROPPED) {
                        _vikingFlagCarrier = self.selectedUnit;
                        _vikingFlagState = TAKEN;
                        NSLog(@"Viking flag picked up!");
                    }
                    else if (tile == _graysFlag.hex && _graysFlagState == DROPPED) {
                        _graysFlagCarrier = self.selectedUnit;
                        _graysFlagState = TAKEN;
                        NSLog(@"Gray flag picked up!");
                    }
                }

            }*/
            
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
                 self.selectedUnit.stats->actionPool > 0 &&
                 [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] == 1)
        {
            if (tile.hexType == ASTEROID)
            {
                EnvironmentEntity* entity = [self getEnvironmentEntityOnHex:tile];
                if ([UnitActions searchThis:entity byThis:self.selectedUnit forVikingFlagLocation:_vikingFlagHidingLocation orGraysFlagLocation: _graysFlagHidingLocation])
                {
                    
                    if (self.selectedUnit.faction == VIKINGS)
                    {
                        if (entity == _graysFlagHidingLocation && _graysFlagState == HIDDEN) {
                            _graysFlagCarrier = self.selectedUnit;
                            _graysFlagState = TAKEN;
                            NSLog(@"Gray flag picked up!");
                        }
                        else if (entity == _vikingFlagHidingLocation && _vikingFlagState == HIDDEN) {
                            _vikingFlagCarrier = self.selectedUnit;
                            _vikingFlagState = TAKEN;
                            NSLog(@"Viking flag picked up!");
                        }
                    }
                    else
                    {
                        if (entity == _vikingFlagHidingLocation && _vikingFlagState == HIDDEN) {
                            _vikingFlagCarrier = self.selectedUnit;
                            _vikingFlagState = TAKEN;
                            NSLog(@"Viking flag picked up!");
                        }
                        else if (entity == _graysFlagHidingLocation && _graysFlagState == HIDDEN) {
                            _graysFlagCarrier = self.selectedUnit;
                            _graysFlagState = TAKEN;
                            NSLog(@"Gray flag picked up!");
                        }
                    }
                }
            }
            else if (tile.hexType == VIKING || tile.hexType == ALIEN)
            {
                if (!unitOnTile.active)
                {
                    if (_graysFlagCarrier == unitOnTile)
                    {
                        _graysFlagCarrier = self.selectedUnit;
                        NSLog(@"Gray flag picked up!");
                    }
                    else if (_vikingFlagCarrier == unitOnTile)
                    {
                        _vikingFlagCarrier = self.selectedUnit;
                        NSLog(@"Viking flag picked up!");
                    }
                }
            }
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
    NSMutableArray* hexagons = [self.map generateDistribution];
    
    for (Hex* hex in hexagons)
    {
        EnvironmentEntity *entity = [[EnvironmentEntity alloc] initWithType: ENV_ASTEROID atPosition:GLKVector3Make(0, 0, 0.1) withRotation:GLKVector3Make(0, 0, 0) andScale:GLKVector3Make(0.005, 0.005, 0.005) onHex:hex];
        
        [environment addObject:entity];
    }
    
    return environment;
}

-(void)update
{
    switch (_vikingFlagState)
    {
        case TAKEN:
            _vikingFlag.position = _vikingFlagCarrier.position;
            break;
        case DROPPED:
            
            break;
        case HIDDEN:
            
            break;
        default:
            break;
    }
    
    switch (_graysFlagState)
    {
        case TAKEN:
            _graysFlag.position = _graysFlagCarrier.position;
            break;
        case DROPPED:
            
            break;
        case HIDDEN:
            
            break;
        default:
            break;
    }
}

-(void)switchTurn
{
    if(self.state == SELECTION)
    {
        [self switchTurnSelecting];
    }
    else if (self.state == FLAG_PLACEMENT)
    {
        [self switchTurnFlagPlacement];
    }
    else if (self.state == PLAYING)
    {
        [self switchTurnPlaying];
        [self respawnUnits];
    }
}

-(void)switchTurnSelecting
{
    NSMutableArray *units = self.whoseTurn == self.p1Faction ? self.p1Units : self.p2Units;
    self.whoseTurn = self.whoseTurn == self.p1Faction ? self.p2Faction : self.p1Faction;
    units = self.whoseTurn == self.p1Faction ? self.p1Units : self.p2Units;
    self.selectionSwitchCount++;
    self.selectedUnit = units[0];
    
    if(self.selectionSwitchCount >= 2)
    {
        self.state = FLAG_PLACEMENT;
        self.selectedUnit = nil;
    }
}

-(void)switchTurnFlagPlacement
{
    self.whoseTurn = self.whoseTurn == VIKINGS ? ALIENS : VIKINGS;
    self.selectedUnit = nil;
    
    if(_graysFlagHidingLocation != nil && _vikingFlagHidingLocation != nil)
    {
        self.state = PLAYING;
    }
}

-(int)checkForFlagCaptureInVikingZone: (NSMutableArray*)vikingCaptureZone andGraysZone: (NSMutableArray*)grayCaptureZone
{
    
    for(Hex* hex in vikingCaptureZone)
    {
        if (hex == _graysFlagCarrier.hex && _graysFlagCarrier.faction == VIKINGS)
        {
            return VIKINGS;
        }
    }
    
    for(Hex* hex in grayCaptureZone)
    {
        if (hex == _vikingFlagCarrier.hex && _vikingFlagCarrier.faction == ALIENS)
        {
            return ALIENS;
        }
    }
    
    return -1;
}

-(void)addToRespawnList:(Unit *)unit
{
    if(!(((Unit *)unit).active))
    {
        if(unit.faction == VIKINGS)
        {
            [self.p1RespawnUnits addObject:((Unit *)unit)];
        }
        else
        {
            [self.p2RespawnUnits addObject:((Unit *)unit)];
        }
    }
}

@end