//
//  NavigationTabBarViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/25/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "NavigationTabBarViewController.h"

@interface NavigationTabBarViewController ()

@end

@implementation NavigationTabBarViewController

- (IBAction)takePicture:(id)sender {
    WavingViewController *wavingViewController = (WavingViewController*)[[self childViewControllers] objectAtIndex:0];
    NSLog(@"taking picture");
    [wavingViewController takepicture];
}

@end
