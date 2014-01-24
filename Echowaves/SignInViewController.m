//
//  SignInViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignInViewController.h"
#import "EWWave.h"

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
        NSLog(@"User %@ already connected with password %@", credential.user, credential.password);
        self.waveName.text = credential.user;
        self.wavePassword.text = credential.password;
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Make sure your segue name in storyboard is the same as this line
//    if ([[segue identifier] isEqualToString:@"TuneIn"])
//    {
//        NSLog(@"----calling prepareForSegue TuneIn");
//    }
//}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"----calling shouldPerformSegueWithIdentifier TuneIn");
    
    if ([identifier isEqualToString:@"TuneIn"]) {
        return NO;
    }
    return YES;
}

@end
