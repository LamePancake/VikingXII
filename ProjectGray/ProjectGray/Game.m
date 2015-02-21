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

-(Game*) init:(int)size{
    _map = [_map initWithSize:size];
    return self;
}

-(Unit *) getUnitOnHex: (Hex *)hex forFaction: (Faction) faction {
    
    NSMutableArray* units = faction == _p1Faction ? _p1Units : _p2Units;
    
    for(Unit* aUnit in units) {
        if(hex == aUnit.hex) return aUnit;
    }
    
    return nil;
}

-(void) updateLegalActionsForUnit:(Unit *)unit{
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


@end