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

@interface Hex : NSObject

@property int r;
@property int q;
@property GLKVector4 colour;

- (id) initWithAxialCoords:(int)q And:(int)r;

- (id) initWithAxialCoords:(int)q And:(int)r AndColour:(GLKVector4)colour;

@end

#endif
