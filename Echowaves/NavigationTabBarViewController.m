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
    UploadProgressViewController *uploadProgressViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"UploadView"];
    [uploadProgressViewController takepicture];

//    [(UINavigationController *)self pushViewController:uploadProgressViewController animated:YES];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.waveName.title = APP_DELEGATE.waveName;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end
