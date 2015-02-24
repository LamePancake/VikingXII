//
//  UnitStats.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnitStats.h"

@interface UnitStats ()

@end

@implementation UnitStats

-(instancetype) init {
    //Stats for light ship type
    _lightShip.hull = 10;
    _lightShip.attRange = 2;
    _lightShip.damage = 2;
    _lightShip.moveRange = 2;
    _lightShip.accuracy = 100.0f;
    _lightShip.critChance = 25.0f;
    _lightShip.critModifier = 1.5f;
    _lightShip.actionsPerTurn = 3;
    _lightShip.engineHealth = 5;
    _lightShip.weaponHealth = 5.0f;
    _lightShip.shipHealth = 10;
    //Stats for medium ship type
    _medShip.hull = 10;
    _medShip.attRange = 2;
    _medShip.damage = 2;
    _medShip.moveRange = 2;
    _medShip.accuracy = 100.0f;
    _medShip.critChance = 25.0f;
    _medShip.critModifier = 1.5f;
    _medShip.actionsPerTurn = 3;
    _medShip.engineHealth = 5;
    _medShip.weaponHealth = 5.0f;
    _medShip.shipHealth = 10;
    //Stats for heavy ship type
    _heavyShip.hull = 10;
    _heavyShip.attRange = 2;
    _heavyShip.damage = 2;
    _heavyShip.moveRange = 2;
    _heavyShip.accuracy = 100.0f;
    _heavyShip.critChance = 25.0f;
    _heavyShip.critModifier = 1.5f;
    _heavyShip.actionsPerTurn = 3;
    _heavyShip.engineHealth = 5;
    _heavyShip.weaponHealth = 5.0f;
    _heavyShip.shipHealth = 10;
    return self;
}
@end