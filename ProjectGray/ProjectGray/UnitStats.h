//
//  UnitStats.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-23.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

struct shipType {
    //stats
    int hull;
    int attRange;
    int damage;
    int moveRange;
    float accuracy;
    float critChance;
    float critModifier;
    int actionsPerTurn;
    //health
    int engineHealth;
    float weaponHealth;
    int shipHealth;
    //assets
    //None for now
};


@interface UnitStats
@property struct shipType lightShip;
@property struct shipType medShip;
@property struct shipType heavyShip;
-(instancetype) init;
@end