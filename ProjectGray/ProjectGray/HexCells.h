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

extern const GLKVector4 DEFAULT_COLOUR;
extern const GLKVector4 ATTACKABLE_COLOUR;
extern const GLKVector4 MOVEABLE_COLOUR;
extern const GLKVector4 SELECTED_COLOUR;
extern const GLKVector4 GRAY_PLACEMENT_COLOUR;
extern const GLKVector4 VIKING_PLACEMENT_COLOUR;

@interface HexCells : NSObject

@property(nonatomic) int numberOfCells;
@property(nonatomic) int N;
@property(nonatomic, strong) NSMutableArray* hexPositions;
@property(nonatomic, strong) NSMutableArray* hexArray;

/**
 * Initialises a hex grid with the given size.
 *
 * @param size_ The hex grid's size. This specifies the "radius" of the grid, i.e.
 *              the number of cells extending in each direction from the centre.
 * @return A hex grid with the specified size.
 */
- (id)initWithSize:(int)size_;

/**
 * Calculates the number of cells in the hex grid given the radius.
 *
 * @param size_ The number of cells extending in each direction from the centre.
 * @return The number of cells in the hex grid given @a size_.
 */
- (int)calculateNumberOfCells:(int)size_;

/**
 * Populates the hex grid.
 *
 * @param size_ The number of cells extending in each direction from the centre.
 */
- (void)generateCells:(int)size_;

/**
 * Inserts a hex cell at the given location in axial coordinates.
 * @param hex The hex cell to insert.
 * @param q   The q coordinate within the grid.
 * @param r   The r coordinate within the grid.
 */
- (void)insertHex:(Hex*)hex atQ:(int)q AndR:(int)r;

/**
 * Gets the hex cell at the given axial coordinates.
 * @param q The q coordinate.
 * @param r The r coordinate.
 @ @return The hex cell at (q, r).
 */
- (Hex*)hexAtQ:(int)q andR:(int)r;

/**
 * Gets the hex cell from the screen coordinates x and y (if any).
 * @param x The x coordinate.
 * @param y The y coordinate.
 */
//- (Hex*)hexFromPixelAtX:(int)x andY:(int)y;

/**
 * Converts cube coordinates to axial coordinates
 * @param cube the cube coordinate
 * @return the axial coordinate
 */
+ (GLKVector2) cubeToAxial:(GLKVector3) cube;

/**
 * Converts axial coordinates to cube coordinates
 * @param q axial Q coordinate
 * @param r axial R coordinate
 * @return the cube coordinate
 */
+ (GLKVector3) axialToCube:(float)q :(float)r;

/**
 * Gets the distance between two hex cells
 * @param q1 first hex q coord
 * @param r1 first hex r coord
 * @param q2 second hex q coord
 * @param r2 second hex r coord
 * @return the number of hexagons between these axial coordinates
 */
+ (int)distance:(int)q1 :(int)r1 :(int)q2 :(int)r2;

/**
 * Determines the shortest distance (number of hex cells) between two hex cells.
 * Note that this method does not perform pathfinding.
 *
 * @param start       The starting hex.
 * @param destination The destination hex.
 * @return The distance in number of tiles between the two hex cells.
 */
+ (int)distanceFrom: (Hex*)start toHex: (Hex*)destination;

- (void)clearColours;

/**
 * Gets the hex cells surrounding @a selectedHex within @a range.
 * @param range The range around the specified cell.
 * @param selectedHex The hex cell around which to find the cells.
 * @return An array of Hex objects surrounding @a selectedHex.
 */
- (NSMutableArray*)movableRange:(int)range from:(Hex *)selectedHex;

/**
 * Determines a traversable path from the starting position (q1, r1) to the destination
 * (q2, r2).
 *
 * @param q1 The q coordinate of the starting position.
 * @param r1 The r coordinate of the starting position.
 * @param q2 The q coordinate of the destination.
 * @param r2 The r coordinate of the destination.
 * @return an array of hex that form a path between these coordinates
 */
- (NSMutableArray*)makePathFrom:(int)q1 :(int)r1 To:(int)q2 :(int)r2;

- (NSMutableArray*)makeFrontierFrom:(int)q1 :(int)r1 inRangeOf:(int)limit;

/**
 * Gets the neighbours of a given hex cell.
 *
 * @param hex The cell whose neighbours are to be found.
 * @return An array of Hex objects neighbouring @a hex.
 */
- (NSMutableArray*)neighbors:(Hex*)hex;

/**
 * Gets the closest hex cell to a given position in world coordinates.
 *
 * @param position The (x, y) coordinates of the world position.
 * @param limit    Whether to limit the search to be within hexagons. If false, the method
 *                 method will return the closest hex cell to a world position even if the
 *                 location is not within the cell's bounds.
 * @return returns the closest hex to the world position
 */
- (Hex*)closestHexToWorldPosition:(GLKVector2) position WithinHexagon:(BOOL)limit;

/**
 * Gets the hex cells that the grays can occupy at the start.
 * @return An array of Hex objects to place the grays in.
 */
- (NSMutableArray*)graysSelectableRange;

/**
 * Gets the hex cells that the vikings can occupy at the start.
 * @return An array of Hex objects to place the vikings in.
 */
- (NSMutableArray*)vikingsSelectableRange;

@end

#endif
