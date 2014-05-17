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
    
    NSLog(@"taking picture");
    APP_DELEGATE.wavingViewController.waving.on = true;
    
    [APP_DELEGATE.wavingViewController takepicture];
}

- (IBAction)pushUpload:(id)sender {
    NSLog(@"pushing upload");
    [APP_DELEGATE checkForUpload];
}

-(void) viewDidLoad {
    [super viewDidLoad];
}

@end
