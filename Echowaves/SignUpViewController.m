//
//  SignUpViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignUpViewController.h"
#import "EWWave.h"
#import "NavigationTabBarViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"------------viewDidLoad");

    _waveName.layer.cornerRadius = 4.0f;
    _waveName.layer.borderWidth = 1.0f;
    _waveName.layer.borderColor= UIColorFromRGB(0xFFA500).CGColor;
    
    _wavePassword.layer.cornerRadius = 4.0f;
    _wavePassword.layer.borderWidth = 1.0f;
    _wavePassword.layer.borderColor= UIColorFromRGB(0xFFA500).CGColor;
    
    _confirmPassword.layer.cornerRadius = 4.0f;
    _confirmPassword.layer.borderWidth = 1.0f;
    _confirmPassword.layer.borderColor= UIColorFromRGB(0xFFA500).CGColor;
    
    _createWaveButton.layer.cornerRadius = 4.0f;
    _createWaveButton.layer.borderWidth = 1.0f;
    _createWaveButton.layer.borderColor= UIColorFromRGB(0xFFA500).CGColor;
}


- (IBAction)createWave:(UIButton *)sender
{
    NSString *wave =self.waveName.text;
    NSString *wavePassword =self.wavePassword.text;
    NSString *confirmPassword =self.confirmPassword.text;
    if(![wave length] || ![wavePassword length] || ![confirmPassword length]) {
        NSString *message = NSLocalizedString(@"All fields are required", nil);
        UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:sender cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [errorMessage show];
        return;
    }
    NSLog(@"-------calling createWave");
    [EWWave showLoadingIndicator:self];
    [EWWave createWaveWithName:wave
                      password:wavePassword
               confirmPassword:confirmPassword
                   success:^(NSString *waveName) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave storeCredentialForWaveName:self.waveName.text withPassword:self.wavePassword.text];

                       NSString *deviceToken=[(EchowavesAppDelegate *)[[UIApplication sharedApplication] delegate] deviceToken];
                       if(deviceToken) {
                       [EWWave storeIosTokenForWave:self.waveName.text
                                              token:[(EchowavesAppDelegate *)[[UIApplication sharedApplication] delegate] deviceToken]
                                            success:^(NSString *waveName) {
                                                NSLog(@"stored device token for: %@", waveName);
                                            }
                                            failure:^(NSString *errorMessage) {
                                                NSLog(@"failed storing deviceToken %@", errorMessage);
                                            }];
                       }
                       [self performSegueWithIdentifier: @"CreateWave" sender: self];
                       
                   }
                   failure:^(NSString *errorMessage) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave showErrorAlertWithMessage:errorMessage FromSender:nil];
                   }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"----------------seguiing");
//    NavigationTabBarViewController *navigationTabBarViewController = segue.destinationViewController;
    
    // Make sure your segue name in storyboard is the same as this line
   if ([[segue identifier] isEqualToString:@"CreateWave"])
    {
        NSLog(@"----calling prepareForSegue CreateWave");
//        navigationTabBarViewController.waveName.title = self.waveName.text;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"----calling shouldPerformSegueWithIdentifier CreateWave");
    
    if ([identifier isEqualToString:@"CreateWave"]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    switch(theTextField.tag)
    {
        case 0:
            [_wavePassword becomeFirstResponder];
            break;
        case 1:
            [_confirmPassword becomeFirstResponder];
            break;
        default:
            [theTextField resignFirstResponder];
            [self createWave:nil];
    }
    return YES;
}

@end
