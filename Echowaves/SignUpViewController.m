//
//  SignUpViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignUpViewController.h"
#import "EWWave.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController


- (IBAction)createWave:(UIButton *)sender {
    NSLog(@"-------calling tuneIn");
    [EWWave showLoadingIndicator:self];
    [EWWave createWaveWithName:self.waveName.text
                      password:self.wavePassword.text
               confirmPassword:self.confirmPassword.text
                   success:^(NSString *waveName) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave storeCredentialForWaveName:self.waveName.text withPassword:self.wavePassword.text];
                       [self performSegueWithIdentifier: @"CreateWave" sender: self];
                       
                   }
                   failure:^(NSString *errorMessage) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave showErrorAlertWithMessage:errorMessage FromSender:self];
                   }];
    
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"----calling shouldPerformSegueWithIdentifier CreateWave");
    
    if ([identifier isEqualToString:@"CreateWave"]) {
        return NO;
    }
    return YES;
}

@end
