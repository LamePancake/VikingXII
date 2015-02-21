//
//  HexCells.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

#ifndef ProjectGray_HexCells_h
#define ProjectGray_HexCells_h

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "Hex.h"

@interface HexCells : NSObject

@property(nonatomic) int numberOfCells;
@property(nonatomic) int N;
@property(nonatomic, strong) NSMutableArray* hexPositions;
@property(nonatomic, strong) NSMutableArray* hexArray;

- (id)initWithSize:(int)size_;

- (int)calculateNumberOfCells:(int)size_;

- (void)generateCells:(int)size_;

- (void)insertHex:(Hex*)hex atQ:(int)q AndR:(int)r;

- (Hex*)hexAtQ:(int)q andR:(int)r;

- (Hex*)hexFromPixelAtX:(int)x andY:(int)y;

- (NSMutableArray*)movableRange:(int)range from:(Hex *)selectedHex;

- (NSMutableArray*)makePathFrom:(int)q1 :(int)r1 To:(int)q2 :(int)r2;

- (NSMutableArray*)neighbors:(Hex*)hex;

- (Hex*)closestHexToWorldPosition:(GLKVector2) position WithinHexagon:(BOOL)limit;

@end

#endif
