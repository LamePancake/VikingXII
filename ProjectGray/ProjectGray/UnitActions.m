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
#import "CTFGameMode.h"
#import "ItemStats.h"

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

-(NSString*)vikingAttackSound
{
    int numberOfSounds = 6;
    int value = arc4random()%numberOfSounds + 1;
    
    switch(value)
    {
        case 1:
            return @"cannon1.aiff";
        case 2:
            return @"cannon2.aiff";
        case 3:
            return @"cannon3.aiff";
        case 4:
            return @"cannon4.aiff";
        case 5:
            return @"cannon5.aiff";
        case 6:
            return @"cannon6.aiff";
        default:
            return @"cannon1.aiff";
    }
}

-(NSString*)alienAttackSound
{
    int numberOfSounds = 4;
    int value = arc4random()%numberOfSounds + 1;
    
    switch(value)
    {
        case 1:
            return @"laser1.wav";
        case 2:
            return @"laser2.wav";
        case 3:
            return @"laser3.wav";
        case 4:
            return @"laser4.wav";
        default:
            return @"laser1.wav";
    }
}

// Calculates the damage and returns whether the attack missed
-(BOOL)calculateDamage: (float*)damageOut forAttackOnTarget: (Unit*)target byAttacker: (Unit*)attacker
{
    float damage = 0.0f;
    BOOL missed = NO;
    
    int hexCellsApart = [HexCells distance:attacker.hex.q :attacker.hex.r :target.hex.q :target.hex.r];
    int close = 2;
    int bordering = 1;
    float accuracy = attacker.stats->accuracy;
    
    if (hexCellsApart == close)
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
        *damageOut = damage;
    }
    
    return missed;
}

- (void)attackThis:(Unit*)target with:(Unit *)attacker
{
    float damage = 0.0f;
    BOOL missed = NO;
    attacker.attacking = YES;
    
    MovementTask *firingMove = nil;
    
    // Check if the attack can even happen
    if(!target.active ||
       !attacker.active ||
       ![attacker ableToAttack] ||
       [HexCells distance:attacker.hex.q :attacker.hex.r :target.hex.q :target.hex.r] > attacker.stats->attackRange)
    {
        return;
    }

    missed = [self calculateDamage:&damage forAttackOnTarget:target byAttacker:attacker];
    attacker.stats->actionPool -= attacker.stats->actionPointsPerAttack;
    if(!missed) target.stats->shipHealth -= damage;

    
    GLKVector3 finalAngle;
    finalAngle = GLKVector3Subtract(target.position, attacker.position);
    finalAngle.z = atan2f(finalAngle.y, finalAngle.x);
    
    Item* projectile = [[Item alloc] initWithFaction:attacker.faction
                                            andClass:(ItemClasses)attacker.shipClass
                                          atPosition:attacker.position
                                        withRotation:GLKVector3Make(attacker.rotation.x, attacker.rotation.y, finalAngle.z)
                                            andScale:GLKVector3Make(PROJECTILE_SCALE, PROJECTILE_SCALE, PROJECTILE_SCALE)
                                               onHex:nil];
    projectile.active = NO;
    [attacker.projectiles addObject:projectile];
    
    // Create the callback to show damage
    NSMethodSignature* methodSig = [GameViewController instanceMethodSignatureForSelector: @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:)];
    NSInvocation* attackCompletion = [NSInvocation invocationWithMethodSignature:methodSig];
    GLKVector3 targetUnitPos = target.position; // Can't pass property to the invocation (or union, as it turns out)
    BOOL isDamage = YES;
    float actualDamage = roundf(damage);
    
    attackCompletion.target = _game.gameVC;
    attackCompletion.selector = @selector(unitHealthChangedAtX:andY:andZ:withChange:andIsDamage:);
    [attackCompletion setArgument:&targetUnitPos.x atIndex:2]; // Index 2 because 0 is target and 1 is _cmd (the selector being sent to the object)
    [attackCompletion setArgument:&targetUnitPos.y atIndex:3];
    [attackCompletion setArgument:&targetUnitPos.z atIndex:4];
    [attackCompletion setArgument:&actualDamage atIndex:5];
    [attackCompletion setArgument:&isDamage atIndex:6];
    
    // Add a completion handler to remove the projectile from the attacker's projectile array once it has struck the enemy
    NSMethodSignature* removeObjSig = [NSMutableArray instanceMethodSignatureForSelector:@selector(removeObject:)];
    NSInvocation* removeProjectileCompletion = [NSInvocation invocationWithMethodSignature:removeObjSig];
    removeProjectileCompletion.target = attacker.projectiles;
    removeProjectileCompletion.selector = @selector(removeObject:);
    [removeProjectileCompletion setArgument:&projectile atIndex:2];
    
    // Create a strike task that removes the projectile from the scene, displays the damage label and plays the strike sound
    // Set it to be the next task invoked after the firing movement task completes
    StrikeTask* strike = [[StrikeTask alloc] initWithProjectile:projectile andTarget:target andGame:_game withSound:@"explosion-metallic.wav"
                                                    andNextTask:nil andCompletion:attackCompletion];
    firingMove = [[MovementTask alloc] initWithGameObject:projectile fromInitial:attacker.position toDestination:target.position andNextTask:strike];
    
    // If the attacker has the vampirism powerup, create an additional callback to display the amount of health they gained
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
        [strike.completionHandler addObjectsFromArray:@[attackCompletion, healCompletion, removeProjectileCompletion]];
    }
    else
    {
        [strike.completionHandler addObjectsFromArray:@[attackCompletion, removeProjectileCompletion]];
    }

    // If the attack killed the target, add a task to set it to inactive after all animations have finished
    if(target.stats->shipHealth <= 0)
    {
        NSMethodSignature* activeSig = [Item instanceMethodSignatureForSelector:@selector(setActive:)];
        NSInvocation* hideShip = [NSInvocation invocationWithMethodSignature:activeSig];
        bool willBeActive = false;
        hideShip.target = target;
        hideShip.selector = @selector(setActive:);
        [hideShip setArgument:&willBeActive atIndex:2];
        
        target.stats->shipHealth = 0;
        [_game unitKilledBy:attacker.faction];
        [_game writeToTextFile];
        
        [strike.completionHandler addObject:hideShip];
        
        // If we're playing CTF, add this unit to the respawn list so that it will respawn after death
        if(_game.mode == CTF)
        {
            NSMethodSignature* respawnSig = [CTFGameMode instanceMethodSignatureForSelector:@selector(addToRespawnList:)];
            NSInvocation* respawnUnitCompletion = [NSInvocation invocationWithMethodSignature:respawnSig];
            respawnUnitCompletion.target = _game;
            respawnUnitCompletion.selector = @selector(addToRespawnList:);
            [respawnUnitCompletion setArgument:&target atIndex:2];
            [strike.completionHandler addObject:respawnUnitCompletion];
        }
    }
    
    // Create a completion handler to re-enable the unit after the attack is complete
    NSMethodSignature* signature = [Unit instanceMethodSignatureForSelector:@selector(setTaskAvailable:)];
    NSInvocation* reEnableAttacker = [NSInvocation invocationWithMethodSignature:signature];
    bool willBeActive = true;
    reEnableAttacker.target = attacker;
    reEnableAttacker.selector = @selector(setTaskAvailable:);
    [reEnableAttacker setArgument:&willBeActive atIndex:2];
    
    // Create another completion handler to show the projectile when the ship has finished rotating
    // Don't need to retain the projCopy since the fireMovement task already has a strong reference to it
    NSMethodSignature* activeSig = [Item instanceMethodSignatureForSelector:@selector(setActive:)];
    NSInvocation* showProjectile = [NSInvocation invocationWithMethodSignature:activeSig];
    showProjectile.target = projectile;
    showProjectile.selector = @selector(setActive:);
    [showProjectile setArgument:&willBeActive atIndex:2];
    
    // Create one file completion handler to play the sound when the ship is finished rotating
    NSString* soundFile = attacker.faction == _game.p1Faction ? [self vikingAttackSound] : [self alienAttackSound];
    BOOL soundShouldLoop = NO;
    NSMethodSignature* playSoundSig = [SoundManager instanceMethodSignatureForSelector:@selector(playSound:looping:)];
    NSInvocation* playFireSound = [NSInvocation invocationWithMethodSignature:playSoundSig];
    playFireSound.target = [SoundManager sharedManager];
    playFireSound.selector = @selector(playSound:looping:);
    [playFireSound setArgument:&soundFile atIndex:2];
    [playFireSound setArgument:&soundShouldLoop atIndex:3];
    
    RotationTask* rotTask = [[RotationTask alloc] initWithGameObject:attacker toAngle:finalAngle andNextTask:firingMove];
    [rotTask.completionHandler addObjectsFromArray: @[reEnableAttacker, showProjectile, playFireSound]];
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