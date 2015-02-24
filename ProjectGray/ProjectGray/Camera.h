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

@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic) GLKMatrix4 projectionMatrix;
@property (nonatomic) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

-(id)initWithWidth:(float)width WithHeight:(float)height WithRadius:(float) radius;
-(void) UpdateWithWidth:(float) w AndHeight:(float) h;
-(void) ZoomDidBegin:(BOOL) begin Scale:(float)scale;
-(void) PanDidBegin:(BOOL) begin X:(float)x Y:(float)y;

@end
#endif
