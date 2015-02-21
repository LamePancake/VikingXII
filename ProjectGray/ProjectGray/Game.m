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
-(void) legalActions:(Hex *)selectedHex currentPlayer:(BOOL)thisPlayer {
    Unit *selectedUnit;
    NSMutableArray *possibleMoves;
    NSMutableArray *possibleAttacks;
    //Look for appropriate Unit on selectedHex
    if(thisPlayer) {
        for(Unit* aUnit in _p1Units) {
            if(selectedHex == aUnit.hex) {//I don't know if this comparison method actually works
                selectedUnit = aUnit;
                break;
            }
        }
    }else {
        for(Unit* aUnit in _p2Units) {
            if(selectedHex == aUnit.hex) {//I don't know if this comparison method actually works
                selectedUnit = aUnit;
                break;
            }
        }
    }
    //Check to see if there was a unit assigned.  If there was no unit on hex, this will be NULL
    if(selectedUnit == NULL) {
        return; //Shouldn't do anything at all
    }else {//Shows legal range of movement
        possibleMoves = [_map movableRange:selectedUnit.moveRange from:selectedHex];
        possibleAttacks = [_map movableRange:selectedUnit.attRange from:selectedHex];
    }
}
@end