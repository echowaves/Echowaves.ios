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
    
    EchowavesAppDelegate *appDelegate = (EchowavesAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.wavingViewController.tabBarController setSelectedIndex:0];
    
    WavingViewController *wavingViewController = appDelegate.wavingViewController;
    
    NSLog(@"taking picture");
    [wavingViewController takepicture];
}

@end
