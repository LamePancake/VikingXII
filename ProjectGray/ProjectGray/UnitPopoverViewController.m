//
//  UnitPopoverViewController.m
//  ProjectGray
//
//  Created by Trevor Ware on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "UnitPopoverViewController.h"

@interface UnitPopoverViewController ()

@end

@implementation UnitPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) updateUnitDescription: desc
{
    [_unitDescription setText:desc];
}

@end
