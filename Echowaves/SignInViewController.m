//
//  SignInViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignInViewController.h"
#import "EWWave.h"
#import "NavigationTabBarViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController


- (IBAction)tuneIn:(UIButton *) sender {
    NSLog(@"-------calling tuneIn");
    [EWWave showLoadingIndicator:self];
    [EWWave tuneInWithName:self.waveName.text
               andPassword:self.wavePassword.text
                   success:^(NSString *waveName) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave storeCredentialForWaveName:self.waveName.text withPassword:self.wavePassword.text];
                       NSString *deviceToken=[(EchowavesAppDelegate *)[[UIApplication sharedApplication] delegate] deviceToken];
                       if(deviceToken) {
                           [EWWave storeIosTokenForWave:self.waveName.text
                                              token:deviceToken
                                            success:^(NSString *waveName) {
                                                NSLog(@"stored device token for: %@", waveName);
                                            }
                                            failure:^(NSString *errorMessage) {
                                                NSLog(@"failed storing deviceToken %@", errorMessage);
                                            }];
                       }
                       [self performSegueWithIdentifier: @"TuneIn" sender: self];
                   }
                   failure:^(NSString *errorMessage) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave showErrorAlertWithMessage:errorMessage FromSender:self];
                   }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLCredential *credential = [EWWave getStoredCredential];
    if(credential) {
        NSLog(@"User %@ already connected with password.", credential.user);
        self.waveName.text = credential.user;
        self.wavePassword.text = credential.password;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"----------------seguiing");
    NavigationTabBarViewController *navigationTabBarViewController = segue.destinationViewController;

    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"TuneIn"])
    {
        NSLog(@"----calling prepareForSegue TuneIn");
        navigationTabBarViewController.waveName.title = self.waveName.text;
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"----calling shouldPerformSegueWithIdentifier TuneIn");
    
    if ([identifier isEqualToString:@"TuneIn"]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if(theTextField.tag==1) {
        [_wavePassword becomeFirstResponder];
    }else{
        [theTextField resignFirstResponder];
        [self tuneIn:nil];
    }
    return YES;
}

@end
