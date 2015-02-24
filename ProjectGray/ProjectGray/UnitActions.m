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
#import "SoundManager.h"
#import "Game.h"

@interface UnitActions ()

@end

@implementation UnitActions

//When these methods are called, they should do a move that is already legal
+ (void)moveThis:(Unit *)mover toHex:(Hex *)hex onMap:(HexCells *)map{
    
    //Call the Task system to animate.  Model should update immediately.
    NSMutableArray *path = [map makePathFrom: mover.hex.q :mover.hex.r To:hex.q :hex.r];
    mover.hex = hex;
    
    MovementTask *nextMove = nil;
    Hex *nextHex = nil;
    
    NSUInteger count = [path count];
    
    for (NSUInteger i = count; i > 0; i--)
    {
        MovementTask *moveTask = [[MovementTask alloc] initWithUnit:mover fromInitial:path[i - 1] toDestination:nextHex andNextTask:nextMove];
        
        nextMove = moveTask;
        nextHex = path[i - 1];
    }
    [[Game taskManager] addTask:nextMove];
}

+ (void)attackThis:(Unit*)target with:(Unit *)attacker {
    
    int hexCellsApart = [HexCells distance:attacker.hex.q :attacker.hex.r :target.hex.q :target.hex.r];
    int close = 2;
    int bordering = 1;
    float accuracy = attacker.accuracy;
    
    if (hexCellsApart > attacker.attRange)
    {
        return; // not in range
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
        return; // miss!
    }
    
    float damage = attacker.weaponHealth * attacker.damage; //percent of weapon health determines damage
    float critRandom = ((double)arc4random() / ARC4RANDOM_MAX); //random float between 0 and 1 - determines if the hit is critical
    
    if (critRandom <= attacker.critChance)
    {
        damage *= attacker.critModifier; //critical hit! booYa!
    }
    
    target.shipHealth -= damage;
    [[SoundManager sharedManager] playSound:@"cannon1.aiff" looping:NO];

    NSLog(@"Attacked unit at hex: and did %f damage leaving the target with %d health", damage, target.shipHealth);
}

+ (void)refillAPFor:(Unit *)thisObject {

}

+ (void)healThis:(Unit *)target byThis:(Unit *)healer {

}
@end