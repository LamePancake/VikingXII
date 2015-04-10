//
//  UnitPopoverViewController.h
//  ProjectGray
//
//  Created by Trevor Ware on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UnitPopoverViewControllerDelegate

-(void)userDataChangedWithDecription:(NSString *)desc;

@end

@interface UnitPopoverViewController : UIViewController

@property (nonatomic, strong) id<UnitPopoverViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *unitDescription;

- (void) updateUnitDescription: desc;

@end
