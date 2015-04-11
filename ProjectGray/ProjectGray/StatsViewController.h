//
//  StatsViewController.h
//  ProjectGray
//
//  Created by Trevor Ware on 2015-03-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController
- (IBAction)backPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *totalGame;
@property (strong, nonatomic) IBOutlet UILabel *vikingWin;
@property (strong, nonatomic) IBOutlet UILabel *vikingKill;
@property (strong, nonatomic) IBOutlet UILabel *grayWin;
@property (strong, nonatomic) IBOutlet UILabel *grayKill;
@property (strong, nonatomic) IBOutlet UILabel *vikingCTF;
@property (strong, nonatomic) IBOutlet UILabel *grayCTF;

@end
