//
//  Game.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "HexCells.h"
#import "Unit.h"
#import "UnitActions.h"

@interface Game : NSObject
{
}

@property (nonatomic) HexCells* map;
@property (nonatomic) NSMutableArray* p1Units;
@property (nonatomic) NSMutableArray* p2Units;

-(void)legalActions:(Hex*)selectedHex currentPlayer:(BOOL)thisPlayer;
@end