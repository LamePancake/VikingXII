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

#define MAX_UNITS 6

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
            return;
        }
        
        // Otherwise, create and add a new alien ship of the selected class
        [_aliens addObject:[[Unit alloc]
                            initWithFaction:ALIENS
                            andClass:chosenClass
                            atPosition:GLKVector3Make(0, 0, 0)
                            withRotation:GLKVector3Make(0, 0, 0)
                            andScale:GLKVector3Make(UNIT_SCALE, UNIT_SCALE, UNIT_SCALE)
                            onHex:nil]];
        _alienCounts[chosenClass]++;
        [_alienLabels[chosenClass] setText:[@(_alienCounts[chosenClass]) stringValue]];
        
        [self updateImage: _AlienImages OfClass: chosenClass IsIncremented: YES];
    }
    // Removed a ship of the chosen class
    else if(_alienCounts[chosenClass] > sender.value)
    {
        // If they somehow managed to remove when there were none, then return
        if(currentAlienCount == 0)
        {
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
        
        [self updateImage: _AlienImages OfClass: chosenClass IsIncremented: NO];
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
            return;
        }
        
        // Otherwise, create and add a new alien ship of the selected class
        [_vikings addObject:[[Unit alloc]
                            initWithFaction:VIKINGS
                            andClass:chosenClass
                            atPosition:GLKVector3Make(0, 0, 0)
                            withRotation:GLKVector3Make(0, 0, 0)
                            andScale:GLKVector3Make(UNIT_SCALE, UNIT_SCALE, UNIT_SCALE)
                            onHex:nil]];
        _vikingCounts[chosenClass]++;
        [_vikingLabels[chosenClass] setText:[@(_vikingCounts[chosenClass]) stringValue]];
        

        [self updateImage: _VikingImages OfClass: chosenClass IsIncremented: YES];
    }
    // Removed a ship of the chosen class
    else if(_vikingCounts[chosenClass] > sender.value)
    {
        // If they somehow managed to remove when there were none, then return
        if(currentVikingCount == 0)
        {
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

        [self updateImage: _VikingImages OfClass: chosenClass IsIncremented: NO];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"ToGame"])
    {
        if([_aliens count] == MAX_UNITS && [_vikings count] == MAX_UNITS)
        {
            return YES;
        }
        else
        {
            if([_aliens count] != MAX_UNITS  && [_vikings count] == MAX_UNITS)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                message:@"Aliens do not have enough units."
                                                               delegate: self
                                                      cancelButtonTitle:@"Continue"
                                                      otherButtonTitles:nil, nil];
                [alert show];

            }
            else if([_aliens count] == MAX_UNITS  && [_vikings count] != MAX_UNITS)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                message:@"Vikings do not have enough units."
                                                               delegate: self
                                                      cancelButtonTitle:@"Continue"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                message:@"Aliens and Vikings do not have enough units."
                                                               delegate: self
                                                      cancelButtonTitle:@"Continue"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            return NO;
        }
    }
    
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ToGame"])
    {
        Game* game;
        
        switch (_settings.currentMode) {
            case SKIRMISH:
            {
                game = [[SkirmishGameMode alloc]
                        initGameMode:SKIRMISH withPlayer1Units:_vikings
                        andPlayer2Units:_aliens
                        andMap:_map];
            } break;
            case CTF:
            {
                game = [[CTFGameMode alloc]
                        initGameMode: CTF withPlayer1Units:_vikings
                        andPlayer2Units:_aliens
                        andMap:_map];
            } break;
            default:
                break;
        }
        
        // Pass the settings object to the game view controller for further use
        GameViewController* gameVC = [segue destinationViewController];
        gameVC.game = game;
    }
}

- (void)updateImage: (NSArray*) images OfClass: (int) chosenClass IsIncremented: (bool) isIncremented
{
    if(isIncremented)
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(1.0,1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(1.3,1.3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(1.0,1.0);
                } completion:nil];
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(1.0,1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(0.7,0.7);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    ((UIImageView *)images[chosenClass]).transform = CGAffineTransformMakeScale(1.0,1.0);
                } completion:nil];
            }];
        }];
    }
}

@end
