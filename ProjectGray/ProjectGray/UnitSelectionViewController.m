//
//  UnitSelectionViewController.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "UnitSelectionViewController.h"
#import "GameViewController.h"
#import "HexCells.h"

#define MAX_UNITS 5

@interface UnitSelectionViewController ()
{
    int _alienCounts[NUM_CLASSES];
    int _vikingCounts[NUM_CLASSES];
    
    NSMutableArray* _vikings;
    NSMutableArray* _aliens;
    
    HexCells* _map;
}

@end

@implementation UnitSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vikings = [[NSMutableArray alloc] init];
    _aliens = [[NSMutableArray alloc] init];
    
    memset(&(_alienCounts[0]), 0, sizeof(int) * NUM_CLASSES);
    memset(&(_vikingCounts[0]), 0, sizeof(int) * NUM_CLASSES);
    
    _map = [[HexCells alloc] initWithSize:_settings.mapSize];
}

- (IBAction)addAlienShip:(UIStepper*)sender {
    
    // Calculate the current number of alien ships
    int currentAlienCount = 0;
    int chosenClass = -1;
    for(int i = 0; i < NUM_CLASSES; i++)
        currentAlienCount += _alienCounts[i];
    
    if(sender == _alienLightStepper) chosenClass = LIGHT;
    else if(sender == _alienMediumStepper) chosenClass = MEDIUM;
    else if(sender == _alienHeavyStepper) chosenClass = HEAVY;
    
    // Added a ship of the chosen class
    if(_alienCounts[chosenClass] < sender.value)
    {
        // Don't add anymore ships if the player has already selected the max number.
        if(currentAlienCount == MAX_UNITS)
        {
            //if(sender == _alienLightStepper) _alienLightStepper.value = _alienLightStepper.value--;
            //else if(sender == _alienMediumStepper) _alienMediumStepper.value = _alienMediumStepper.value--;
            //else if(sender == _alienHeavyStepper) _alienHeavyStepper.value = _alienHeavyStepper.value--;
            return;
        }
        
        // Otherwise, create and add a new alien ship of the selected class
        [_aliens addObject:[[Unit alloc]
                            initWithFaction:ALIENS
                            andClass:chosenClass
                            atPosition:GLKVector3Make(0, 0, 0)
                            withRotation:GLKVector3Make(0, 0, 0)
                            andScale:UNIT_SCALE
                            onHex:nil]];
        _alienCounts[chosenClass]++;
        [_alienLabels[chosenClass] setText:[@(_alienCounts[chosenClass]) stringValue]];
    }
    // Removed a ship of the chosen class
    else if(_alienCounts[chosenClass] > sender.value)
    {
        // If they somehow managed to remove when there were none, then return
        if(currentAlienCount == 0)
        {
            //if(sender == _alienLightStepper) _alienLightStepper.value = _alienLightStepper.value++;
            //else if(sender == _alienMediumStepper) _alienMediumStepper.value = _alienMediumStepper.value++;
            //else if(sender == _alienHeavyStepper) _alienHeavyStepper.value = _alienHeavyStepper.value++;
            return;
        }
        
        // Remove the first ship of that type in the array
        for(Unit* ship in _aliens)
        {
            if(ship.shipClass == chosenClass)
            {
                [_aliens removeObject:ship];
                break;
            }
        }
        _alienCounts[chosenClass]--;
        [_alienLabels[chosenClass] setText:[@(_alienCounts[chosenClass]) stringValue]];
    }
}

- (IBAction)addVikingShip:(UIStepper*)sender {
    // Calculate the current number of viking ships
    int currentVikingCount = 0;
    int chosenClass;

    for(int i = 0; i < NUM_CLASSES; i++)
        currentVikingCount += _vikingCounts[i];
    
    if(sender == _vikingLightStepper) chosenClass = LIGHT;
    else if(sender == _vikingMediumStepper) chosenClass = MEDIUM;
    else if(sender == _vikingHeavyStepper) chosenClass = HEAVY;
    
    // Added a ship of the chosen class
    if(_vikingCounts[chosenClass] < sender.value)
    {
        // Don't add anymore ships if the player has already selected the max number.
        if(currentVikingCount == MAX_UNITS)
        {
            if(sender == _vikingLightStepper) _vikingLightStepper.value = _vikingLightStepper.value--;
            else if(sender == _vikingMediumStepper) _vikingMediumStepper.value = _vikingMediumStepper.value--;
            else if(sender == _vikingHeavyStepper) _vikingHeavyStepper.value = _vikingHeavyStepper.value--;
            return;
        }
        
        // Otherwise, create and add a new alien ship of the selected class
        [_vikings addObject:[[Unit alloc]
                            initWithFaction:VIKINGS
                            andClass:chosenClass
                            atPosition:GLKVector3Make(0, 0, 0)
                            withRotation:GLKVector3Make(0, 0, 0)
                            andScale:UNIT_SCALE
                            onHex:nil]];
        _vikingCounts[chosenClass]++;
        [_vikingLabels[chosenClass] setText:[@(_vikingCounts[chosenClass]) stringValue]];
    }
    // Removed a ship of the chosen class
    else if(_vikingCounts[chosenClass] > sender.value)
    {
        // If they somehow managed to remove when there were none, then return
        if(currentVikingCount == 0)
        {
            if(sender == _vikingLightStepper) _vikingLightStepper.value = _vikingLightStepper.value++;
            else if(sender == _vikingMediumStepper) _vikingMediumStepper.value = _vikingMediumStepper.value++;
            else if(sender == _vikingHeavyStepper) _vikingHeavyStepper.value = _vikingHeavyStepper.value++;
            return;
        }
        // Remove the first ship of that type in the array
        for(Unit* ship in _vikings)
        {
            if(ship.shipClass == chosenClass)
            {
                [_vikings removeObject:ship];
                break;
            }
        }
        _vikingCounts[chosenClass]--;
        [_vikingLabels[chosenClass] setText:[@(_vikingCounts[chosenClass]) stringValue]];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"ToGame"]) {
        return [_aliens count] == MAX_UNITS && [_vikings count] == MAX_UNITS;
    }
    
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ToGame"])
    {
        Game* game = [[Game alloc]
                      initWithMode:[[_settings.currentMode alloc] init]
                      andPlayer1Units:_vikings
                      andPlayer2Units:_aliens
                      andMap:_map];
        // Pass the settings object to the game view controller for further use
        GameViewController* gameVC = [segue destinationViewController];
        gameVC.game = game;
    }
}

@end
