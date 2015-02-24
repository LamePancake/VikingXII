//
//  Camera.h
//  ProjectGray
//
//  Created by Trevor Ware on 2015-02-04.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_Camera_h
#define ProjectGray_Camera_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@interface Camera : NSObject

// The modelview matrix
@property (nonatomic) GLKMatrix4 modelViewMatrix;

// The projection matrix
@property (nonatomic) GLKMatrix4 projectionMatrix;

// The final matrix, modelview multiplied by the projection matrix
@property (nonatomic) GLKMatrix4 modelViewProjectionMatrix;

// The normal matrix
@property (nonatomic) GLKMatrix3 normalMatrix;

-(id)initWithWidth:(float)width WithHeight:(float)height WithRadius:(float) radius;

/**
 * Updates the mode, view and projection matricies
 *
 * @param w. The width of the screen.
 * @param h. The height of the screen.
 */
-(void) UpdateWithWidth:(float) w AndHeight:(float) h;

/**
 * Performs a zooming on the modelview matrix
 *
 * @param begin True if the zoom just started.
 * @param scale The scale factor of the zoom.
 */
-(void) ZoomDidBegin:(BOOL) begin Scale:(float)scale;

/**
 * Translates the camera in a pan effect.
 *
 * @param begin True if the pan just started.
 * @param x The translation in the x direction.
 * @param y The translation in the y direction.
 */
-(void) PanDidBegin:(BOOL) begin X:(float)x Y:(float)y;

@end
#endif
