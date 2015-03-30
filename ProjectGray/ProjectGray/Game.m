//
//  Game.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

//#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#import <Foundation/Foundation.h>
#import "Game.h"
#import "GameViewController.h"

#import "MovementTask.h"
#include "NSMutableArray_Shuffling.h"

static Game* _game = nil;

@interface Game ()
{
    NSMutableArray* _p1SelectableRange;
    NSMutableArray* _p2SelectableRange;
}


@end

@implementation Game
-(instancetype) initGameMode: (GameMode) mode withPlayer1Units: (NSMutableArray*)p1Units andPlayer2Units: (NSMutableArray*)p2Units andMap: (HexCells *)map
                   andGameVC: (GameViewController*) gameVC
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
        _p1RespawnUnits = [[NSMutableArray alloc] init];
        _p2RespawnUnits = [[NSMutableArray alloc] init];
        
        _environmentEntities = [[NSMutableArray alloc] init];
        _gameVC = gameVC;
        
        // Get the spawn areas for each
        _p1SelectableRange = [_map vikingsSelectableRange];
        _p2SelectableRange = [_map graysSelectableRange];

        _actions = [[UnitActions alloc] initWithGame:self];
    }
    [self saveScores];
    return self;
}

- (NSMutableArray*) generateEnvironment
{
    NSMutableArray* environment = [[NSMutableArray alloc] init];
    
    return environment;
}

-(void)dealloc {
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

-(void)update
{
    
}

-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange {}

-(void)selectTile:(Hex *)tile {}

-(void)switchTurn
{
    if(_state == SELECTION)
    {
        [self switchTurnSelecting];
    }
    else
    {
        [self respawnUnits];        
        [self switchTurnPlaying];

    }
}


-(void)respawnUnits
{
    if(_whoseTurn == VIKINGS)
    {
        for(Unit *unit in _p1RespawnUnits)
        {
            unit.active = true;
            unit.stats->shipHealth += 100;
            
            NSMutableArray * spawnCells = [_map vikingsSelectableRange];
            [spawnCells shuffle];
            for(int i = 0; i < spawnCells.count; i++)
            {
                if(((Hex*)spawnCells[i]).hexType == EMPTY)
                {
                    unit.hex.hexType = EMPTY;
                    unit.position = GLKVector3Make(((Hex*)spawnCells[i]).worldPosition.x, ((Hex*)spawnCells[i]).worldPosition.y, unit.position.z);
                    unit.hex = spawnCells[i];
                    unit.hex.hexType = VIKING;
                    break;
                }
            }
            [_p1RespawnUnits removeObject:unit];
        }
    }
    else
    {
        for(Unit *unit in _p2RespawnUnits)
        {
            unit.active = true;
            unit.stats->shipHealth += 100;
            
            NSMutableArray * spawnCells = [_map graysSelectableRange];
            [spawnCells shuffle];
            for(int i = 0; i < spawnCells.count; i++)
            {
                if(((Hex*)spawnCells[i]).hexType == EMPTY)
                {
                    unit.hex.hexType = EMPTY;
                    unit.position = GLKVector3Make(((Hex*)spawnCells[i]).worldPosition.x, ((Hex*)spawnCells[i]).worldPosition.y, unit.position.z);
                    unit.hex = spawnCells[i];
                    unit.hex.hexType = ALIEN;
                    break;
                }
            }
            [_p2RespawnUnits removeObject:unit];
        }
    }
}

-(void)switchTurnSelecting
{
    NSMutableArray *units = _whoseTurn == _p1Faction ? _p1Units : _p2Units;
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

-(BOOL)saveScores {
//    NSString *pathName = @"/Users/a00795612/Desktop/8081 Project/comp8051_group1/ProjectGray/testSave";
//    [[NSFileManager defaultManager] createFileAtPath:pathName contents:nil attributes:nil];
//    NSString *str = @"testString";
//    [str writeToFile:pathName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self writeToTextFile];
    [self readTextFile];
    return false;
}

-(void) writeToTextFile{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt", documentsDirectory];
    //create content - four lines of text
    NSString *content = @"One<data>Two<data>Three<data>Four<data>Five";
    //save content to the documents directory
    [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

-(void) readTextFile{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt", documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil];
    NSArray *dataSegments = [content componentsSeparatedByString:@"<data>"];
    //printf("%s", [content UTF8String]);
    //use simple alert from my library (see previous post for details)
//    [ASFunctions alert:content];
//    [content release];
}

@end