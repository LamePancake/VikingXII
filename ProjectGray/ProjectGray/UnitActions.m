//
//  UnitActions.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#define ARC4RANDOM_MAX      0x100000000
#import <Foundation/Foundation.h>
#import "UnitActions.h"
#import "HexCells.h"

@interface UnitActions ()

@end

@implementation UnitActions
+(int)moveThis:(Unit *)mover toHex:(Hex *)hex{
    return 1;
}
+(float)attackThis:(Unit*)attacker with:(Unit *)target {
    
    int hexCellsApart = [HexCells distance:attacker.hex.q :attacker.hex.r :target.hex.q :target.hex.r];
    int close = 2;
    int bordering = 1;
    float accuracy = attacker.accuracy;
    
    if (hexCellsApart > attacker.attRange)
    {
        return 0; // not in range
    }
    else if (hexCellsApart == close)
    {
        accuracy += 0.10f;
    }
    else if (hexCellsApart == bordering)
    {
        accuracy += 0.20f;
    }
    
    float hitRandom = ((double)arc4random() / ARC4RANDOM_MAX); //random float between 0 and 1 - determines if there's a hit
    if (hitRandom > accuracy)
    {
        return 0; // miss!
    }
    
    float damage = attacker.weaponHealth * attacker.damage; //percent of weapon health determines damage
    float critRandom = ((double)arc4random() / ARC4RANDOM_MAX); //random float between 0 and 1 - determines if the hit is critical
    
    if (critRandom <= attacker.critChance)
    {
        damage *= attacker.critModifier; //critical hit! booYa!
    }
    
    return damage;
}
+(int)refillAPFor:(Unit *)thisObject{
    return 1;
}
+(int)healThis:(Unit *)target byThis:(Unit *)healer{
    return 1;
}
@end