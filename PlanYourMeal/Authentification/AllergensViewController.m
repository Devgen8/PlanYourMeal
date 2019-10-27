//
//  AllergensViewController.m
//  PlanYourMeal
//
//  Created by мак on 27/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

#import "AllergensViewController.h"
#import "PlanYourMeal-Swift.h"

@interface AllergensViewController ()

@end

@implementation AllergensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)finishTapped:(UIButton *)sender {
    self.view.window.rootViewController = [[TabBarViewController alloc] init];
    [self.view.window makeKeyAndVisible];
}


@end
