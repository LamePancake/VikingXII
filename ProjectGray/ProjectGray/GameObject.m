//
//  GameObject.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Hex.h"
#import "GameObjectData.h"

@interface GameObject ()
    @property Hex* position; //Variable for object's current position on a map
    @property int objectType; //Placeholder for specific type of object
    @property GameObjectData* data; //Data unique to a type of object
    @property int apPool;//GameObject's current available actionpoints
@end

@implementation GameObject

-(int) getRange:(int)range {
    return [_data getMoveSpeed];
}

@end