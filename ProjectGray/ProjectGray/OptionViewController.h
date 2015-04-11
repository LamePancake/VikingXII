//
//  OptionViewController.h
//  ProjectGray
//
//  Created by Matthew Ku on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionViewController : UIViewController

//Saved Options
@property (nonatomic) int volumeSound, volumeMusic, skipScene;
@property (strong, nonatomic) IBOutlet UISlider *musicVolume;
@property (strong, nonatomic) IBOutlet UISlider *soundVolume;
@property (strong, nonatomic) IBOutlet UIButton *skipSceneButton;

/**
 * Saves the scores of the players
 */
-(BOOL)saveScores;

/**
 * Method writes a string to a text file
 */
-(void) writeToTextFile;

/**
 * Method retrieves content from documents directory and displays it in an alert
 */
-(void) readTextFile;

@end
