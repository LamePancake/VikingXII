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
#import "Game.h"
#import "factionmodel.h"

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
@property (strong, nonatomic) IBOutlet UIImageView *selectedUnitVIew;
@property (strong, nonatomic) IBOutlet UILabel *selectedUnitLabel;
@property (strong, nonatomic) IBOutlet UIImageView *turnImage;


@end
