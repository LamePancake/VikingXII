//
//  MainViewController.m
//  
//
//  Created by Tim Wang on 2015-01-30.
//
//

#import "MainViewController.h"
#import "GameViewController.h"
#import "Settings.h"

@interface MainViewController ()

@property(strong, nonatomic) Settings* gameSettings;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialise the game settings object
    _gameSettings = [[ Settings alloc] init];
    [self updateModeText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @brief Switches the current mode to the next mode in the list.
 * @param sender The button which triggered the event.
 */
- (IBAction)onModeScrollForward:(id)sender {

    [_gameSettings switchToNextMode];
    // Update the model & view
    [self updateModeText];
}

/**
 * @brief Switches the current mode to the previous on in the list.
 * @param sender The button which triggered the event.
 */
- (IBAction)onModeScrollBack:(id)sender {
    // Update the model & view
    [_gameSettings switchToPrevMode];
    [self updateModeText];
}

/**
 * @brief Updates the current mode in the model and view.
 */
-(void)updateModeText {
    NSString *modeTxt = [_gameSettings getModeName];
    [_curModeLabel setText: modeTxt];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ToUnitSel"])
    {
    
        // Pass the settings object to the game view controller for further use
        GameViewController* unitSelVC = [segue destinationViewController];
        unitSelVC.settings = _gameSettings;
    }
}


@end
