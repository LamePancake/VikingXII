//
//  TutorialViewController.m
//  ProjectGray
//
//  Created by Trevor Ware on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()
{
    NSString* images[13];
    int counter;
}

@end

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    counter = 0;
    for(int i = 1; i < 14; i++)
    {
        images[i - 1] = [NSString stringWithFormat:@"tutorial-%d.png",i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (IBAction)backPressed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"BackPressed.png"] forState:UIControlStateHighlighted];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [sender setImage:[UIImage imageNamed:@"BackPressed.png"] forState:UIControlStateNormal];
        ((UIButton*)sender).transform = CGAffineTransformMakeScale(0.8,0.8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIButton*)sender).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
        
        [sender setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    }];
    
    counter--;
    if(counter < 0)
    {
        [self performSegueWithIdentifier:@"ToTitleFromTutorial" sender:self];
    }
    else
    {
        UIImage * toImage = [UIImage imageNamed:images[counter]];
        [UIView transitionWithView:_tutorialView
                          duration:0.5f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _tutorialView.image = toImage;
                        } completion:nil];
    }

}

- (IBAction)nextPressed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"NextPressed.png"] forState:UIControlStateHighlighted];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [sender setImage:[UIImage imageNamed:@"NextPressed.png"] forState:UIControlStateNormal];
        ((UIButton*)sender).transform = CGAffineTransformMakeScale(0.8,0.8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIButton*)sender).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
        
        [sender setImage:[UIImage imageNamed:@"Next.png"] forState:UIControlStateNormal];
    }];

    counter++;
    if(counter > 12)
    {
        [self performSegueWithIdentifier:@"ToTitleFromTutorial" sender:self];
    }
    else
    {
        UIImage * toImage = [UIImage imageNamed:images[counter]];
        [UIView transitionWithView:_tutorialView
                          duration:0.5f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _tutorialView.image = toImage;
                        } completion:nil];
    }
}

- (IBAction)unwindToTutorial:(UIStoryboardSegue *)unwindSegue
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
