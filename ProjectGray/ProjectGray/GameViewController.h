//
//  GameViewController.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Unit.h"
#import "CTFMode.h"
#import "Settings.h"
#import "factionmodel.h"

@class Game;

@interface GameViewController : GLKViewController
- (IBAction)endTurnPressed:(id)sender;
- (IBAction)pausePresssed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *statsLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLabel;
@property (strong, nonatomic) IBOutlet UILabel *attackLabel;



@property (strong, nonatomic) Settings* settings;
@property (strong, nonatomic) Game* game;

@property (strong, nonatomic) IBOutlet UIImageView *turnMarker;
@property (strong, nonatomic) IBOutlet UIImageView *statsBackground;
@property (strong, nonatomic) IBOutlet UIButton *attackAbilityButton;
@property (strong, nonatomic) IBOutlet UIButton *moveAbilityButton;
@property (strong, nonatomic) IBOutlet UIButton *healAbilityButton;
@property (strong, nonatomic) IBOutlet UIButton *searchAbilityButton;
@property (strong, nonatomic) IBOutlet UIButton *scoutAbilityButton;
@property (strong, nonatomic) IBOutlet UIButton *hammerAbilityButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectedUnitVIew;
@property (strong, nonatomic) IBOutlet UILabel *selectedUnitLabel;
@property (strong, nonatomic) IBOutlet UIImageView *turnImage;
@property (strong, nonatomic) IBOutlet UILabel *apLabel;
- (IBAction)resumeButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *pausedView;

@property (strong, nonatomic) IBOutlet UIImageView *goalImage;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *abilityButtons;
@property (weak, nonatomic) IBOutlet UIView *winView;
@property (weak, nonatomic) IBOutlet UIImageView *winImageView;

/**
 * Notifies the game that the given faction has won.
 * @param winner The winning faction.
 */
-(void)factionDidWin: (Faction)winner;

/**
 * Notifies the game that a given unit was attacked.
 * @param x        The X coordinate of the affected unit's position.
 * @param y        The Y coordinate of the affected unit's position.
 * @param z        The Z coordinate of the affected unit's position.
 * @param change   The amount by which the health changed.
 * @param isDamage Whether the change was damage, healing or a missed attack.
 */
-(void)unitHealthChangedAtX: (float)x andY: (float)y andZ: (float)z withChange: (float)change andIsDamage: (bool) isDamage;

/**
 * Displays the current goal, eg. fight, place flages, etc
 */
- (void)displayGoal;

/**
 * Displays the current turn.
 */
- (void)displayTurn;

/**
 * Updates the current ability image.
 */
- (void)updateAbility;

@end
