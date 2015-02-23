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
#import "ConvoyMode.h"
#import "SkirmishMode.h"

@interface GameViewController : GLKViewController
- (IBAction)endTurnPressed:(id)sender;
- (IBAction)pausePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *statsLabel;

@end
