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

static NSMutableArray* currentPath;

@interface UnitActions ()

@end

@implementation UnitActions

//When these methods are called, they should do a move that is already legal
+ (void)moveThis:(Unit *)mover toHex:(Hex *)hex onMap:(HexCells *)map
{
    if(!mover.active)
    {
        NSLog(@"Unit is dead!");
        return;
    }
    
    //Call the Task system to animate.  Model should update immediately.
    NSMutableArray *path = [map makePathFrom: mover.hex.q :mover.hex.r To:hex.q :hex.r];
    NSUInteger requiredAP = [path count] - 1;
    
    if (requiredAP > [mover moveRange])
    {
        NSLog(@"Not enough action points! needed: %d, in pool: %d", requiredAP, mover.stats->actionPool);
        return;
    }
    
    mover.stats->actionPool -= requiredAP;
    
    // TODO: Create "changeHex" method in Unit to handle this maybe
    mover.hex.hexType = EMPTY;
    mover.hex = hex;
    if (mover.faction == VIKINGS)
    {
        hex.hexType = VIKING;
    }
    else if (mover.faction == ALIENS)
    {
        hex.hexType = ALIEN;
    }
    
    currentPath = path;
    
    // The path is arranged from goal->start
    // We want to want to add goal->goal - 1, goal - 1 -> goal - 2, ... goal - n -> start
    // Should end up with [path count - 1] iterations of our loop
    id<Task> nextTask = nil;
    NSUInteger count = [path count] - 1;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        Hex* initHex = (Hex*)path[i + 1];
        Hex* destHex = (Hex*)path[i];
        
        GLKVector3 finalAngle;
        
        // Determine the angle which the ship must face before traveling to the next hex
        // Note: The coordinates are for some reason reflected along the r axis
        if(destHex.q == initHex.q + 1 && destHex.r == initHex.r)          finalAngle = GLKVector3Make(0, 0, M_PI / 6);
        else if(destHex.q == initHex.q && destHex.r == initHex.r + 1)     finalAngle = GLKVector3Make(0, 0, 3 * M_PI / 6);
        else if(destHex.q == initHex.q - 1 && destHex.r == initHex.r + 1) finalAngle = GLKVector3Make(0, 0, 5 * M_PI / 6);
        else if(destHex.q == initHex.q - 1 && destHex.r == initHex.r)     finalAngle = GLKVector3Make(0, 0, 7 * M_PI / 6);
        else if(destHex.q == initHex.q && destHex.r == initHex.r - 1)     finalAngle = GLKVector3Make(0, 0, 9 * M_PI / 6);
        else if(destHex.q == initHex.q + 1 && destHex.r == initHex.r - 1) finalAngle = GLKVector3Make(0, 0, 11 * M_PI / 6);
        
        GLKVector3 initPos = GLKVector3Make(initHex.worldPosition.x, initHex.worldPosition.y, mover.position.z);
        GLKVector3 destPos = GLKVector3Make(destHex.worldPosition.x, destHex.worldPosition.y, mover.position.z);
        
        //
        MovementTask* currentMove = [[MovementTask alloc] initWithGameObject:mover fromInitial:initPos toDestination:destPos andNextTask:nextTask];
        RotationTask* rotTask = [[RotationTask alloc] initWithGameObject:mover toAngle:finalAngle andNextTask:currentMove];
        nextTask = rotTask;
    }
    
    NSMethodSignature* sig = [UnitActions methodSignatureForSelector:@selector(testHandler:)];
    NSInvocation* testInvocation = [NSInvocation invocationWithMethodSignature:sig];
    NSString* test = @"test";
    
    [testInvocation setSelector:@selector(testHandler:)];
    [testInvocation setArgument:&test atIndex:2]; // 2 Because 0 is self and 1 is _cmd
    [testInvocation setTarget:[UnitActions class]];
    nextTask.completionHandler = testInvocation;
    
    [[Game taskManager] addTask:nextTask];
}

+ (void)testHandler: (NSString*) toLog
{
    NSLog(@"Testing: %@", toLog);
}

+ (void)attackThis:(Unit*)target with:(Unit *)attacker
{
    attacker.attacking = YES;
    
    MovementTask *firingMove = nil;
    if(!target.active)
    {
        NSLog(@"Target is dead!");
        return;
    }
    
    if(!attacker.active)
    {
        NSLog(@"attacker is dead!");
        return;
    }
    
    [[SoundManager sharedManager] playSound:@"cannon1.aiff" looping:NO];
    
    if (![attacker ableToAttack])
    {
        NSString *info = [NSString stringWithFormat:@"Not enough action points! needed: %d, in pool: %d", attacker.stats->actionPointsPerAttack, attacker.stats->actionPool];
        [UnitActions setAttackInfo:info];
        return;
    }
    
    attacker.stats->actionPool -= attacker.stats->actionPointsPerAttack;
    
    int hexCellsApart = [HexCells distance:attacker.hex.q :attacker.hex.r :target.hex.q :target.hex.r];
    int close = 2;
    int bordering = 1;
    float accuracy = attacker.stats->accuracy;
    
    if (hexCellsApart > attacker.stats->attackRange)
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
    
    float damage = attacker.stats->weaponHealth * attacker.stats->damage; //percent of weapon health determines damage
    float critRandom = ((double)arc4random() / ARC4RANDOM_MAX); //random float between 0 and 1 - determines if the hit is critical
    
    if (critRandom <= attacker.stats->critChance)
    {
        damage *= attacker.stats->critModifier; //critical hit! booYa!
    }
    
    target.stats->shipHealth -= damage;
    if(target.stats->shipHealth <= 0)
    {
        target.stats->shipHealth = 0;
        target.active = false;
    }

    NSString *info = [NSString stringWithFormat:@"Attacked unit at hex: and did %f damage leaving the target with %d health", damage, target.stats->shipHealth];
    
    attacker.projectile.position = attacker.position;
    attacker.projectile.rotation = attacker.rotation;
    firingMove = [[MovementTask alloc] initWithGameObject:attacker.projectile fromInitial:attacker.position toDestination:target.position andNextTask:nil];
    [[Game taskManager] addTask:firingMove];
    [UnitActions setAttackInfo:info];
}

+ (void)refillAPFor:(Unit *)thisObject {

}

+ (void)healThis:(Unit *)target byThis:(Unit *)healer
{
    if (![healer ableToHeal]) return;
    else healer.stats->actionPool -= healer.stats->actionPointsPerHeal;
    
    if (!target.active) {
        target.active = true;
        NSLog(@"Revived buddy!");
    }
    
    target.stats->shipHealth += 20;
    NSLog(@"Added health to buddy.");
}

+(BOOL)searchThis:(EnvironmentEntity*)target byThis:(Unit*)searcher forVikingFlagLocation: (EnvironmentEntity*) vikingAsteroid orGraysFlagLocation:(EnvironmentEntity*) graysAsteroid
{
    
    NSLog(@"Searching");
    
    if (target == graysAsteroid || target == vikingAsteroid)
    {
        return true;
    }
    
    return false;
}

+(void)scoutThis:(Unit*)target with:(Unit*)scouter
{
    scouter.attacking = YES;
    
    MovementTask *firingMove = nil;
    if(!target.active)
    {
        NSLog(@"Target is dead!");
        return;
    }
    
    if(!scouter.active)
    {
        NSLog(@"attacker is dead!");
        return;
    }
    
    [[SoundManager sharedManager] playSound:@"cannon1.aiff" looping:NO];
    
    if (![scouter ableToAttack])
    {
        NSString *info = [NSString stringWithFormat:@"Not enough action points! needed: %d, in pool: %d", scouter.stats->actionPointsPerAttack, scouter.stats->actionPool];
        [UnitActions setAttackInfo:info];
        return;
    }
    
    scouter.stats->actionPool -= scouter.stats->actionPointsPerAttack;
}

+ (NSMutableArray *)getCurrentPath {
    return currentPath;
}

+ (void) setAttackInfo:(NSString*)info
{
    attackInfo = info;
}

+(NSString*) getAttackInfo
{
    return attackInfo;
}

@end