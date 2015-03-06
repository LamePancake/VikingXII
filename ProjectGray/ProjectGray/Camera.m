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
    
    float _radius;
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
        _modelViewMatrix = GLKMatrix4Identity;
        _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, -30 * M_PI / 180, 1.0, 0.0, 0.0);
        _modelViewMatrix = GLKMatrix4Translate(_modelViewMatrix, 0.0f, 2.5, -4.0f);
        _projectionMatrix = GLKMatrix4Identity;
        _normalMatrix = GLKMatrix3Identity;
    }
    return self;
}

-(id)initWithWidth:(float)width WithHeight:(float)height WithRadius:(float)radius
{
    self = [super init];
    if (self)
    {
        _translationStart = GLKVector2Make(0, 0);
        _translationEnd = GLKVector2Make(0, 0);
        _scale = 1;
        _lastScale = 1;
        _modelViewMatrix = GLKMatrix4Identity;
        _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, -30 * M_PI / 180, 1.0, 0.0, 0.0);
        _modelViewMatrix = GLKMatrix4Translate(_modelViewMatrix, 0.0f, 2.5, -4.0f);
        _projectionMatrix = GLKMatrix4Identity;
        _normalMatrix = GLKMatrix3Identity;
        _width = width;
        _height = height;
        _radius = radius/3;
    }
    return self;

}

-(void)UpdateWithWidth:(float)w AndHeight:(float)h
{
    _width = w;
    _height = h;
    
    _modelViewMatrix = GLKMatrix4Identity;
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, -30 * M_PI / 180, 1.0f, 0.0f, 0.0f);
    _modelViewMatrix = GLKMatrix4Translate(_modelViewMatrix, 0.0f, 2.5f, 0.0f);
    _modelViewMatrix = GLKMatrix4Translate(_modelViewMatrix, _translationEnd.x, _translationEnd.y, -4.0f/ _scale);
       
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), 0);
    
    float aspect = fabsf(_width / _height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(55.0f), aspect, 0.1f, 100.0f);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
}

-(void) ZoomDidBegin:(BOOL) begin Scale:(float)scale
{
    if(begin)
        _lastScale = _scale;
    
    _scale = _lastScale * scale;
    
    [self KeepInBounds];
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
    
    [self KeepInBounds];
}

-(void) KeepInBounds
{
    if(_scale > 10)
        _scale = 10;
    else if(_scale < 1)
        _scale = 1;

    if(_translationEnd.x <= -_radius * _scale * 0.75)
        _translationEnd.x = -_radius * _scale * 0.75;
    
    if(_translationEnd.x >= _radius * _scale * 0.75)
        _translationEnd.x = _radius * _scale * 0.75;
    
    if(_translationEnd.y <= -_radius * _scale * 0.75)
        _translationEnd.y = -_radius * _scale * 0.75;
    
    if(_translationEnd.y >= _radius * _scale * 0.75)
        _translationEnd.y = _radius * _scale * 0.75;
}

@end