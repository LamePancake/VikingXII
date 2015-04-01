//
//  StatsViewController.m
//  ProjectGray
//
//  Created by Trevor Ware on 2015-03-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadStats];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (IBAction)unwindToStats:(UIStoryboardSegue *)unwindSegue
{
    
}
-(void) loadStats {
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt", documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil];
    NSArray *dataSegments = [content componentsSeparatedByString:@"<data>"];
    if(dataSegments.count == 5) {
        self.vikingKill.text = [NSString stringWithFormat:@"Viking Kills: %@", (NSString*)dataSegments[0]];
        self.grayKill.text = [NSString stringWithFormat:@"Gray Kills: %@", (NSString*)dataSegments[1]];
        self.vikingWin.text = [NSString stringWithFormat:@"Viking Wins: %@", (NSString*)dataSegments[2]];
        self.grayWin.text = [NSString stringWithFormat:@"Gray Wins: %@", (NSString*)dataSegments[3]];
        self.totalGame.text = [NSString stringWithFormat:@"Total Games: %@", (NSString*)dataSegments[4]];
    }
}

@end
