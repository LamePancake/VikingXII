//
//  Hex.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-09.
//  Copyright (c) 2015 DanielRussell. All rights reserved.
//

#ifndef ProjectGray_Hex_h
#define ProjectGray_Hex_h

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"


typedef enum HexType
{
    EMPTY,
    ALIEN,
    VIKING,
    ASTEROID
} HexType;

@interface Hex : NSObject <NSCopying>

@property int r;
@property int q;
@property enum HexType hexType;
@property int instanceVertexIndex;
@property GLKVector2 worldPosition;
@property GLKVector4 colour;

- (id) initWithAxialCoords:(int)q And:(int)r WithIndex:(int)index AndWorldPosition:(GLKVector2)world;

- (id) initWithAxialCoords:(int)q And:(int)r AndColour:(GLKVector4)colour WithIndex:(int)index AndWorldPosition:(GLKVector2)world;


@end

#endif
