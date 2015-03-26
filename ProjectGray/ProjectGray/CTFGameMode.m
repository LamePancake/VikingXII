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

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 * @param alienRange a range of hex cells that can be selected by the aliens.
 * @param vikingRange a range of hex cells that can be selected by the vikings.
 */
-(void)selectTile: (Hex*)tile WithAlienRange: (NSMutableArray*) alienRange WithVikingRange: (NSMutableArray*) vikingRange
{
    
}

/**
 * Handles all logic dealing with the selection of a given tile given the current game state. Moves units,
 * attacks, schedules tasks, etc.
 *
 * @param tile The hex tile that was selected.
 */
-(void)selectTile: (Hex*)tile
{
    
}

-(int)checkForWin
{
    return -1;
}

@end