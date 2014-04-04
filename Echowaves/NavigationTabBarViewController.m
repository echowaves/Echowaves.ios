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
    
//    EchowavesAppDelegate *appDelegate = (EchowavesAppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    
//    UploadProgressViewController *uploadProgressViewController = appDelegate.uploadProgressViewController;
    
    
    NSLog(@"taking picture");
    APP_DELEGATE.wavingViewController.waving.on = true;
    
    [APP_DELEGATE.wavingViewController takepicture];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.waveName.title = APP_DELEGATE.waveName;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end
