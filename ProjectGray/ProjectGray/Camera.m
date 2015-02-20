//
//  Camera.m
//  ProjectGray
//
//  Created by Trevor Ware on 2015-02-04.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#include "Camera.h"

@interface Camera()
{
    GLKVector2  _translationStart;
    GLKVector2  _translationEnd;
    
    float _scale;
    float _lastScale;
    
    float _width;
    float _height;
}


@end

@implementation Camera

-(id) init
{
    self = [super init];
    if (self)
    {
        _translationStart = GLKVector2Make(0, 0);
        _translationEnd = GLKVector2Make(0, 0);
        _scale = 1;
        _lastScale = 1;
        _modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
        _projectionMatrix = GLKMatrix4Identity;
        _normalMatrix = GLKMatrix3Identity;
    }
    return self;
}

-(id)initWithWidth:(float)width WithHeight:(float)height
{
    self = [super init];
    if (self)
    {
        _translationStart = GLKVector2Make(0, 0);
        _translationEnd = GLKVector2Make(0, 0);
        _scale = 1;
        _lastScale = 1;
        _modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f,-4.0f);
        _projectionMatrix = GLKMatrix4Identity;
        _normalMatrix = GLKMatrix3Identity;
        _width = width;
        _height = height;
    }
    return self;

}

-(void)Update
{
    _modelViewMatrix = GLKMatrix4MakeTranslation(_translationEnd.x, _translationEnd.y, -4.0f/ _scale);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), 0);
    
    float aspect = fabsf(_width / _height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
}

-(void) ZoomDidBegin:(BOOL) begin Scale:(float)scale
{
    if(begin)
        _lastScale = _scale;
    
    _scale = _lastScale * scale;
    
    if(_scale > 6)
        _scale = 6;
    else if(_scale < 1)
        _scale = 1;
}

-(void) PanDidBegin:(BOOL) begin X:(float)x Y:(float)y
{
    if(begin)
        _translationStart = GLKVector2Make(0.0f, 0.0f);
    
    x = x * (1 / _scale) * 5.0;
    y = y * (1 / _scale) * 5.0;
    
    float dx = _translationEnd.x + (x - _translationStart.x);
    float dy = _translationEnd.y - (y - _translationStart.y);
    
    _translationEnd = GLKVector2Make(dx, dy);
    _translationStart = GLKVector2Make(x, y);
}

@end