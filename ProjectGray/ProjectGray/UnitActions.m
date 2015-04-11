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
#import "GameViewController.h"
#import "Game.h"

static NSMutableArray* currentPath;

@interface UnitActions ()
{
    Game* _game;
}
@end

@implementation UnitActions

-(instancetype)initWithGame:(Game *)game
{
    if((self = [super init]))
    {
        _game = game;
    }
    return self;
}

//When these methods are called, they should do a move that is already legal
- (id<Task>)moveThis:(Unit *)mover toHex:(Hex *)hex onMap:(HexCells *)map
{
    if(!mover.active)
    {
        // Notify GameViewController
        return nil;
    }
    
    //Call the Task system to animate.  Model should update immediately.
    NSMutableArray *path = [map makePathFrom: mover.hex.q :mover.hex.r To:hex.q :hex.r];
    NSUInteger requiredAP = [path count] - 1;
    
    if (requiredAP > [mover moveRange])
    {
        // Notify GameViewController
        return nil;
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
    
    // Sets the completion handler to make the unit active again after movement
    NSMethodSignature* signature = [Unit instanceMethodSignatureForSelector:@selector(setTaskAvailable:)];
    NSInvocation* moveCompletion = [NSInvocation invocationWithMethodSignature:signature];
    bool willBeActive = true;
    moveCompletion.target = mover;
    moveCompletion.selector = @selector(setTaskAvailable:);
    [moveCompletion setArgument:&willBeActive atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
    
    NSUInteger count = [path count] - 1;
    for (NSUInteger i = 0; i < count; i++)
    {
        Hex* initHex = (Hex*)path[i + 1];
        Hex* destHex = (Hex*)path[i];
        
        GLKVector3 finalAngle;
        
        // Determine the angle which the ship must face before traveling to the next hex
        // Note: Hex coordinates are reflected on the r axis
        if(destHex.q == initHex.q + 1 && destHex.r == initHex.r)          finalAngle = GLKVector3Make(0, 0, M_PI / 6);
        else if(destHex.q == initHex.q && destHex.r == initHex.r + 1)     finalAngle = GLKVector3Make(0, 0, 3 * M_PI / 6);
        else if(destHex.q == initHex.q - 1 && destHex.r == initHex.r + 1) finalAngle = GLKVector3Make(0, 0, 5 * M_PI / 6);
        else if(destHex.q == initHex.q - 1 && destHex.r == initHex.r)     finalAngle = GLKVector3Make(0, 0, 7 * M_PI / 6);
        else if(destHex.q == initHex.q && destHex.r == initHex.r - 1)     finalAngle = GLKVector3Make(0, 0, 9 * M_PI / 6);
        else if(destHex.q == initHex.q + 1 && destHex.r == initHex.r - 1) finalAngle = GLKVector3Make(0, 0, 11 * M_PI / 6);
        
        GLKVector3 initPos = GLKVector3Make(initHex.worldPosition.x, initHex.worldPosition.y, mover.position.z);
        GLKVector3 destPos = GLKVector3Make(destHex.worldPosition.x, destHex.worldPosition.y, mover.position.z);
        
        MovementTask* currentMove = [[MovementTask alloc] initWithGameObject:mover fromInitial:initPos toDestination:destPos andNextTask:nextTask];
        RotationTask* rotTask = [[RotationTask alloc] initWithGameObject:mover toAngle:finalAngle andNextTask:currentMove];
        nextTask = rotTask;
        
        if(i == 0)
        {
            // Add a completion handler
            [currentMove.completionHandler addObject:moveCompletion];
        }
    }
    return nextTask;
}


- (void)destroyAsteroid:(EnvironmentEntity*)asteroid with:(Unit*)attacker
{
    if (![attacker ableToAttack])
    {
        return;
    }
    
    attacker.stats->actionPool -= attacker.stats->actionPointsPerAttack;
    asteroid.hex.hexType = EMPTY;
    asteroid.active = false;
}

- (void)attackThis:(Unit*)target with:(Unit *)attacker
{
    float damage = 0.0f;
    BOOL missed = NO;
    attacker.attacking = YES;
    
    MovementTask *firingMove = nil;
    if(!target.active)
    {
        return;
    }
    
    if(!attacker.active)
    {
        return;
    }
    
    if (![attacker ableToAttack])
    {
        return;
    }
    
    if (attacker.faction == VIKINGS)
    {
        [[SoundManager sharedManager] playSound:@"cannon1.aiff" looping:NO];
    }
    else
    {
        [[SoundManager sharedManager] playSound:@"laser4.wav" looping:NO];
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
    missed = hitRandom > accuracy;
    
    // Don't bother with the damage calculations if the attacker missed.
    if(!missed)
    {
        damage = attacker.stats->damage * (1.0f - target.stats->hull);
        float critRandom = ((double)arc4random() / ARC4RANDOM_MAX); //random float between 0 and 1 - determines if the hit is critical
        
        if (critRandom <= attacker.stats->critChance)
        {
            damage *= attacker.stats->critModifier; //critical hit! booYa!
        }
        
        target.stats->shipHealth -= damage;
        if(target.stats->shipHealth <= 0)
        {
            target.stats->shipHealth = 0;
            [_game unitKilledBy:attacker.faction];
            [_game writeToTextFile];
        }
    }
    
    attacker.projectile.position = attacker.position;
    attacker.projectile.rotation = attacker.rotation;
    attacker.projectile.active = YES;
    
    // Create the callback to show damage
    NSMethodSignature* methodSig = [GameViewController instanceMethodSignatureForSelector: @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:)];
    NSInvocation* attackCompletion = [NSInvocation invocationWithMethodSignature:methodSig];
    GLKVector3 targetUnitPos = target.position; // Can't pass property to the invocation (or union, as it turns out)
    BOOL isDamage = YES;
    float actualDamage = roundf(damage);
    
    NSMethodSignature* signature = [Unit instanceMethodSignatureForSelector:@selector(setActive:)];
    NSInvocation* rotCompletion = [NSInvocation invocationWithMethodSignature:signature];
    bool willBeActive = true;
    rotCompletion.target = attacker;
    rotCompletion.selector = @selector(setTaskAvailable:);
    [rotCompletion setArgument:&willBeActive atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
    
    attackCompletion.target = _game.gameVC;
    attackCompletion.selector = @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:);
    [attackCompletion setArgument:&targetUnitPos.x atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
    [attackCompletion setArgument:&targetUnitPos.y atIndex:3];
    [attackCompletion setArgument:&targetUnitPos.z atIndex:4];
    [attackCompletion setArgument:&actualDamage atIndex:5];
    [attackCompletion setArgument:&isDamage atIndex:6];
    
    GLKVector3 finalAngle;
    finalAngle = GLKVector3Subtract(target.position, attacker.position);
    finalAngle.z = atan2f(finalAngle.y, finalAngle.x);
    
    // Create a strike task that removes the projectile from the scene, displays the damage label and plays the strike sound
    StrikeTask* strike = [[StrikeTask alloc] initWithProjectile:attacker.projectile andTarget:target andGame:_game withSound:@"explosion-metallic.wav"
                                                    andNextTask:nil andCompletion:attackCompletion];
    firingMove = [[MovementTask alloc] initWithGameObject:attacker.projectile fromInitial:attacker.position toDestination:target.position andNextTask:strike];
    RotationTask* rotTask = [[RotationTask alloc] initWithGameObject:attacker toAngle:finalAngle andNextTask:firingMove];
    
    if (attacker.powerUp == VAMPIRISM)
    {
        attacker.stats->shipHealth += damage;
        
        NSMethodSignature* healMethodSig = [GameViewController instanceMethodSignatureForSelector: @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:)];
        NSInvocation* healCompletion = [NSInvocation invocationWithMethodSignature:healMethodSig];
        BOOL damaging = NO;
        GLKVector3 attackerUnitPos = attacker.position;
        healCompletion.target = _game.gameVC;
        healCompletion.selector = @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:);
        [healCompletion setArgument:&attackerUnitPos.x atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
        [healCompletion setArgument:&attackerUnitPos.y atIndex:3];
        [healCompletion setArgument:&attackerUnitPos.z atIndex:4];
        [healCompletion setArgument:&actualDamage atIndex:5];
        [healCompletion setArgument:&damaging atIndex:6];
        
        [strike.completionHandler addObjectsFromArray:@[attackCompletion, healCompletion]];
    }
    else
    {
        [strike.completionHandler addObject:attackCompletion];

    }
    
    if (target.stats->shipHealth <= 0)
    {
        NSMethodSignature* killMethodSig = [Unit instanceMethodSignatureForSelector: @selector(setActive:)];
        NSInvocation* killCompletion = [NSInvocation invocationWithMethodSignature:killMethodSig];
        BOOL isActive = false;
        killCompletion.target = target;
        killCompletion.selector = @selector(setActive:);
        [killCompletion setArgument:&isActive atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
        [strike.completionHandler addObject:killCompletion];
    }
    
    [rotTask.completionHandler addObject:rotCompletion];
    [_game.taskManager addTask:rotTask];
    
}

- (void)refillAPFor:(Unit *)thisObject {

}

- (void)healThis:(Unit *)target byThis:(Unit *)healer
{
    if (![healer ableToHeal]) return;
    else healer.stats->actionPool -= healer.stats->actionPointsPerHeal;
    
    if (!target.active) {
        target.active = true;
    }
    
    target.stats->shipHealth += 20;
    
    // Notify the game view controller that one of the units was healed
    GLKVector3 pos = target.position;
    [_game.gameVC unitHealthChangedAtX:pos.x andY:pos.y andZ:pos.z withChange:20 andIsDamage:false];
}

-(BOOL)searchThisForPowerUps:(EnvironmentEntity*)target byThis:(Unit*)searcher
{
    if (target.percentSearched < 100.0f)
    {
        target.percentSearched += 33.33f;
        searcher.stats->actionPool--;
        
        if (ceilf(target.percentSearched) >= 100.0f)
        {
            target.percentSearched = 100.0f;
            
            if (target.powerUp != NOPOWERUP)
            {
                [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:NO foundPowerUp:target.powerUp];
                return true;
            }
        }
    }
    [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:NO foundPowerUp:target.powerUp];
    return false;
}

-(BOOL)searchThisForPowerUps:(EnvironmentEntity*)target byThis:(Unit*)searcher forVikingFlagLocation: (EnvironmentEntity*) vikingAsteroid orGraysFlagLocation:(EnvironmentEntity*) graysAsteroid
{
    
    if (target.percentSearched < 100.0f || (target == vikingAsteroid || target == graysAsteroid))
    {
        target.percentSearched += 33.33f;
        searcher.stats->actionPool--;
        
        if (ceilf(target.percentSearched) >= 100.0f)
        {
            target.percentSearched = 100.0f;
            
            if (target == graysAsteroid)
            {
                [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:YES foundPowerUp:target.powerUp];
                return true;
            }
            
            if (target == vikingAsteroid) {
                [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:YES foundPowerUp:target.powerUp];
                return true;
            }
            
            if (target.powerUp != NOPOWERUP)
            {
                [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:NO foundPowerUp:target.powerUp];
                return true;
            }
        }
    }
    
    [_game.gameVC asteroidSearchedPercent:target.percentSearched atX:target.position.x andY:target.position.y  andZ:target.position.z foundFlag:NO foundPowerUp:target.powerUp];
    
    return false;
}

-(Unit*)scoutThis:(Unit*)target with:(Unit*)scouter
{
    if(![scouter ableToScout]) return scouter;

    if(!target.active)
    {
        return target;
    }
    
    if(!scouter.active)
    {
        return target;
    }
    
    if (![scouter ableToScout])
    {
        return scouter;
    }
    
    scouter.stats->actionPool -= scouter.stats->actionPointsPerScout;
    return target;
}

- (NSMutableArray *)getCurrentPath {
    return currentPath;
}
@end