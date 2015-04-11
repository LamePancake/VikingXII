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

@property (nonatomic, strong) UIPopoverController *unitDescriptionPopover;

@end

@implementation UnitSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vikings = [[NSMutableArray alloc] init];
    _aliens = [[NSMutableArray alloc] init];
    
    memset(&(_alienCounts[0]), 0, sizeof(int) * NUM_CLASSES);
    memset(&(_vikingCounts[0]), 0, sizeof(int) * NUM_CLASSES);
    
    for(int i = 0; i < NUM_CLASSES; i++)
    {
        [_aliens addObject:[[Unit alloc]
                            initWithFaction:ALIENS
                            andClass:i
                            atPosition:GLKVector3Make(0, 0, 0)
                            withRotation:GLKVector3Make(0, 0, 0)
                            andScale:GLKVector3Make(UNIT_SCALE, UNIT_SCALE, UNIT_SCALE)
                            onHex:nil]];
        
        _alienCounts[i]++;
        [_alienLabels[i] setText:[@(_alienCounts[i]) stringValue]];
        
        [_vikings addObject:[[Unit alloc]
                             initWithFaction:VIKINGS
                             andClass:i
                             atPosition:GLKVector3Make(0, 0, 0)
                             withRotation:GLKVector3Make(0, 0, 0)
                             andScale:GLKVector3Make(UNIT_SCALE, UNIT_SCALE, UNIT_SCALE)
                             onHex:nil]];
        
        _vikingCounts[i]++;
        [_vikingLabels[i] setText:[@(_vikingCounts[i]) stringValue]];
    }
    
    [_unitCountLabel[ALIENS] setText:[NSString stringWithFormat:@"%d / %d", NUM_CLASSES, MAX_UNITS]];
    [_unitCountLabel[VIKINGS] setText:[NSString stringWithFormat:@"%d / %d", NUM_CLASSES, MAX_UNITS]];
    
    _map = [[HexCells alloc] initWithSize:_settings.mapSize];
    
    if(_settings.currentMode == SKIRMISH)
        [_titleLabel setText:@"Skirmish Mode"];
    else
        [_titleLabel setText:@"CTF Mode"];
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
        currentAlienCount++;
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
        currentAlienCount--;
    }
    
    [_unitCountLabel[ALIENS] setText:[NSString stringWithFormat:@"%d / %d", currentAlienCount, MAX_UNITS]];
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
        currentVikingCount++;
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
        currentVikingCount--;
    }
    
    [_unitCountLabel[VIKINGS] setText:[NSString stringWithFormat:@"%d / %d", currentVikingCount, MAX_UNITS]];
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
        
        // Pass the settings object to the game view controller for further use
        GameViewController* gameVC = [segue destinationViewController];
        
        switch (_settings.currentMode) {
            case SKIRMISH:
            {
                game = [[SkirmishGameMode alloc]
                        initGameMode:SKIRMISH withPlayer1Units:_vikings
                        andPlayer2Units:_aliens
                        andMap:_map
                        andGameVC:gameVC];
            } break;
            case CTF:
            {
                game = [[CTFGameMode alloc]
                        initGameMode: CTF withPlayer1Units:_vikings
                        andPlayer2Units:_aliens
                        andMap:_map
                        andGameVC:gameVC];
            } break;
            default:
                break;
        }
        
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

- (IBAction)unwindToUnitSelection:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)dealloc
{
    NSLog(@"Dealloced bitch");
}

- (IBAction)backPressed:(id)sender
{
    
    [sender setImage:[UIImage imageNamed:@"BackPressed.png"] forState:UIControlStateHighlighted];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [sender setImage:[UIImage imageNamed:@"BackPressed.png"] forState:UIControlStateNormal];
        ((UIButton*)sender).transform = CGAffineTransformMakeScale(0.8,0.8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIButton*)sender).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
        
        [sender setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    }];
}

- (IBAction)showUnitDescription:(id)sender
{
    NSString* desc = @"";
    NSString* title = @"";
    NSString* image = @"";
    
    switch ([sender tag])
    {
        case 0:
        {
            title = @"Vör’s Vengeance";
            image = @"l_viking.png";
            desc = @"The sleek, speedy, lightly armoured Viking combat ship designed for quick striking. Named after the Norse goddess of wisdom and this ship is perfect for reconnaissance and quick response. Inspired by the Viking longships of old, the Viking Raider gains additional style points for dual rocket boosters.\r\rBest sailed with beard-braids, drunken bare-chestedness and sea shanties.\r\rSpecial Ability: Scout ";
            break;
        }
        case 1:
        {
            title = @"EIR XII";
            image = @"m_viking.png";
            desc = @"Named after the Norse goddess of healing, Eir XII has been equipped with disposable cannonball dwarves dedicated to repair and revive ally units. Though it does not pack a heavy punch on its own, it can turn the tide of battle by ensuring ally units laugh off enemy attacks.\r\rWhy should death ever be an option?\r\rSpecial Ability: Repair and Revive";
            break;
        }
        case 2:
        {
            title = @"Angry Týr";
            image = @"h_viking.png";
            desc = @"With the Norse god of war and the skies as its namesake this slow moving, heavily armoured ship stops for no one. Its short attack range is offset by the idea that no amount of firing power is too much firing power. With an overload of weapons, Angry Týr shreds all obstacles be it enemies, asteroids, or obese elephants.\r\rThe ideal debt collector.\r\rSpecial Ability: Path Clearing";
            break;
        }
        case 3:
        {
            title = @"Classic Sauce";
            image = @"l_gray.png";
            desc = @"Inspiring conspiracy theories for decades, this gray alien classic combines maneuverability, scouting ability, and orifice probes. Ideal for information gathering and fast travel, this alien ship gives residents around the universe reasons to put on tinfoil hats at night.\r\rShiny. Metal. Saucer-shaped.\r\rSpecial Ability: Scout";
            break;
        }
        case 4:
        {
            title = @"Snail Mail";
            image = @"m_gray.png";
            desc = @"Taking inspiration from a human viral video of a rocket propelled snail, this alien healer ship offers more than just stylish antennas. Packed with super high tech nano quantum polymer magic, this ship ensures other alien crafts can endure many a mean stare by repairing and reviving them. This craft is not slow by any means despite its form inspirations.\r\rSpace travelling snail, minus all the gooey ooziness.\r\rSpecial Ability: Repair and Revive";
            break;
        }
        case 5:
        {
            title = @"Phoenix Special";
            image = @"h_gray.png";
            desc = @"Commonly referred to as the Phoenix triangles by the humans since the sightings in the late 1990’s, these pizza shaped alien ships are the enforcers of the alien fleet. Equipped with more than just flashing lights, this ship has more lasers than all the raves of the world combined. This slow moving ship is all business with its heavy armour and firepower.\r\rYou don’t take a bite out of this pizza, it takes a bite out of you.\r\rSpecial Ability: Path Clearing";
            break;
        }
    }
    
    UnitPopoverViewController *unitpopoverViewController = [[UnitPopoverViewController alloc] initWithNibName:@"UnitPopoverViewController" bundle:nil];
    unitpopoverViewController.delegate = self;
    
    self.unitDescriptionPopover = [[UIPopoverController alloc] initWithContentViewController:unitpopoverViewController];
    self.unitDescriptionPopover.popoverContentSize = CGSizeMake(400.0, 600.0);
    [self.unitDescriptionPopover presentPopoverFromRect:[(UIButton *)sender frame]
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
    
    [unitpopoverViewController updateUnitDescription:desc Title:title Image:image];
    
}
@end
