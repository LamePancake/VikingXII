//
//  MainViewController.m
//  
//
//  Created by Tim Wang on 2015-01-30.
//
//

#import "MainViewController.h"
#import "SkirmishMode.h"
#import "ConvoyMode.h"

@interface MainViewController ()

@property(strong, nonatomic) NSArray* modes;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modes = @[ [ [ConvoyMode alloc] init], [ [SkirmishMode alloc] init]];
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

@end
