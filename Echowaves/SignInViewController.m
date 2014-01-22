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

    [EWWave storeCredentialForWaveName:self.waveName.text withPassword:self.wavePassword.text];

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

@end
