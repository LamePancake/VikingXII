//
//  UnitSelectionViewController.h
//  ProjectGray
//
//  Created by Shane Spoor on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "UnitStats.h"
#import "SkirmishGameMode.h"
#import "CTFGameMode.h"

@interface UnitSelectionViewController : UIViewController

@property (strong, nonatomic) Settings* settings;

// Steppers for the viking ships
@property (weak, nonatomic) IBOutlet UIStepper *vikingLightStepper;
@property (weak, nonatomic) IBOutlet UIStepper *vikingMediumStepper;
@property (weak, nonatomic) IBOutlet UIStepper *vikingHeavyStepper;

// Steppers for the alien ships
@property (weak, nonatomic) IBOutlet UIStepper *alienLightStepper;
@property (weak, nonatomic) IBOutlet UIStepper *alienMediumStepper;
@property (weak, nonatomic) IBOutlet UIStepper *alienHeavyStepper;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *vikingLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *alienLabels;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *VikingImages;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *AlienImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *unitCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end
