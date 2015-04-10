//
//  CTFGameMode.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-25.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFGameMode.h"
#import "UnitActions.h"
#import "GameViewController.h"
#import "PickupFlagTask.h"

@interface CTFGameMode ()

@property NSMutableArray* p1CaptureRange;
@property NSMutableArray* p2CaptureRange;

@end

@implementation CTFGameMode

-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map andGameVC:(GameViewController *)gameVC
{
    if((self = [super initGameMode:mode withPlayer1Units:p1Units andPlayer2Units:p2Units andMap:map andGameVC:gameVC]))
    {
        _graysFlag = [[Item alloc]initWithFaction:self.p1Faction
                                         andClass:FLAG
                                       atPosition:GLKVector3Make(0, 0, 0.05)
                                     withRotation:GLKVector3Make(0, 0, 0)
                                         andScale:GLKVector3Make(0.01, 0.01, 0.01)
                                            onHex:nil];
        _vikingFlag = [[Item alloc]initWithFaction:self.p2Faction
                                          andClass:FLAG
                                        atPosition:GLKVector3Make(0, 0, 0.05)
                                      withRotation:GLKVector3Make(0, 0, 0)
                                          andScale:GLKVector3Make(0.01, 0.01, 0.01)
                                             onHex:nil];
        
        self.environmentEntities = [self generateEnvironment];
        
        _p1CaptureRange = [self.map setupVikingsCaptureRange];
        _p2CaptureRange = [self.map setupGraysCaptureRange];
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
        if (tile.hexType == ASTEROID) return;
        
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
    
    [self.gameVC updateAbility];
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
    
    BOOL healedUnit = NO;
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
                [self.actions destroyAsteroid:entity with:self.selectedUnit];
                
                if (entity.active == false)
                {
                    if (_vikingFlagHidingLocation == entity)
                    {
                        _vikingFlagState = DROPPED;
                        _vikingFlag.hex = entity.hex;
                        entity.hex.hexType = EMPTY;
                    }
                    
                    if (_graysFlagHidingLocation == entity)
                    {
                        _graysFlagState = DROPPED;
                        _graysFlag.hex = entity.hex;
                        entity.hex.hexType = EMPTY;
                    }
                }
            }
            
        }
        // Attack the enemy if possible
        else if(self.selectedUnitAbility == ATTACK &&
                unitOnTile != nil &&
                unitOnTile.faction != self.selectedUnit.faction && [HexCells distanceFrom:unitOnTile.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            [self.actions attackThis:unitOnTile with:self.selectedUnit];
            [self addToRespawnList:unitOnTile];
        }
        // Move to another tile
        else if(self.selectedUnitAbility == MOVE &&
                tile.hexType == EMPTY &&
                [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] <= self.selectedUnit.moveRange)
        {
            id<Task> tasks = [self.actions moveThis:self.selectedUnit toHex:tile onMap:self.map];
            
            if (_vikingFlag.hex == tile || _graysFlag.hex == tile)
            {
                id<Task> currentTask;
                currentTask = tasks;
                
                while (currentTask.nextTask != nil) {
                    currentTask = currentTask.nextTask;
                }
                
                if (_vikingFlag.hex == tile) {
                    _vikingFlagCarrier = self.selectedUnit;
                }
                if (_graysFlag.hex == tile) {
                    _graysFlagCarrier = self.selectedUnit;
                }
                
                id<Task> pickupFlag = [[PickupFlagTask alloc] initWithGameObject:self.selectedUnit vikingFlagState:&_vikingFlagState vikingFlag:_vikingFlag vikingFlagCarrier:_vikingFlagCarrier graysFlagState:&_graysFlagState graysFlag:_graysFlag graysFlagCarrier:_graysFlagCarrier];
                
                currentTask.nextTask = pickupFlag;
            }
            
            [[Game taskManager] addTask:tasks];
        }
        // Heal a member of your faction
        else if (self.selectedUnitAbility == HEAL &&
                 unitOnTile != nil &&
                 unitOnTile.faction == self.whoseTurn &&
                 [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            healedUnit = [self.selectedUnit ableToHeal];
            [self.actions healThis:unitOnTile byThis:self.selectedUnit];
        }
        // Scout the enemy if possible
        else if(self.selectedUnitAbility == SCOUT &&
                unitOnTile != nil &&
                unitOnTile.faction != self.selectedUnit.faction && [HexCells distanceFrom:unitOnTile.hex toHex:self.selectedUnit.hex] <= self.selectedUnit.stats->attackRange)
        {
            self.selectedScoutedUnit = [self.actions scoutThis:unitOnTile with:self.selectedUnit];
        }
        else if (self.selectedUnitAbility == SEARCH &&
                 self.selectedUnit.stats->actionPool > 0 &&
                 [HexCells distanceFrom:tile toHex:self.selectedUnit.hex] == 1)
        {
            if (tile.hexType == ASTEROID)
            {
                EnvironmentEntity* entity = [self getEnvironmentEntityOnHex:tile];
                if ([self.actions searchThisForPowerUps:entity byThis:self.selectedUnit forVikingFlagLocation:_vikingFlagHidingLocation orGraysFlagLocation: _graysFlagHidingLocation])
                {
                    if (entity.powerUp != NOPOWERUP)
                    {
                        NSLog(@"PoweredUp!");
                        [self activatePowerUp:entity.powerUp forUnit:self.selectedUnit];
                        entity.powerUp = NOPOWERUP;
                    }
                    
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
    if(!healedUnit && unitOnTile && unitOnTile.faction == self.whoseTurn)
    {
        self.selectedUnit = unitOnTile;
        self.selectedUnitAbility = MOVE;
    }
    
    // Check if anyone has won and notify the game
    int winner = [self checkForFlagCapture];
    if(winner != -1) [self.gameVC factionDidWin: winner];
    
    [self.gameVC updateAbility];
}

- (NSMutableArray*) generateEnvironment
{
    NSMutableArray* environment = [[NSMutableArray alloc] init];
    NSMutableArray* hexagons = [self.map generateDistribution];
    
    for (Hex* hex in hexagons)
    {
        EnvironmentEntity *entity = [[EnvironmentEntity alloc] initWithType: ENV_ASTEROID_VAR1 atPosition:GLKVector3Make(0, 0, 0.1) withRotation:GLKVector3Make(0, 0, 0) andScale:GLKVector3Make(0.005, 0.005, 0.005) onHex:hex];
        
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
        [self.gameVC displayGoal];
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
        [self.gameVC displayGoal];
    }
}

-(int)checkForFlagCapture
{
    for(Hex* hex in _p1CaptureRange)
    {
        if (hex == _graysFlagCarrier.hex && _graysFlagCarrier.faction == self.p1Faction)
        {
            return VIKINGS;
        }
    }
    
    for(Hex* hex in _p2CaptureRange)
    {
        if (hex == _vikingFlagCarrier.hex && _vikingFlagCarrier.faction == self.p2Faction)
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