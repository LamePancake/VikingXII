//
//  TutorialViewController.h
//  ProjectGray
//
//  Created by Trevor Ware on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *tutorialView;
- (IBAction)backPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
