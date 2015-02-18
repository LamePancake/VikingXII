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


@interface GameObject ()
    @property Hex* position; //Placeholder variable for object's current position on a map
    @property int objectType; //Placeholder for specific type of object
@property GameObject* data; //Placeholder for data unique to a type of object
    @property int apPool;//Placeholder for GameObject's current available actionpoints
@end

@implementation GameObject
//Currently no methods to implement - will add as need for functionality arises.
@end