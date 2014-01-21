//
//  SignUpViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
- (IBAction)tuneIn:(UIButton *) sender {
    
    NSURLCredential *credential;
    credential = [NSURLCredential credentialWithUser:[self.waveName text] password:[self.wavePassowrd text] persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:SignUpViewController.echowavesProtectionSpace];
    
}

- (IBAction)createWave:(UIButton *)sender {
}


+ (NSURLProtectionSpace*) echowavesProtectionSpace {
    NSURL *url = [NSURL URLWithString:@"http://echowaves.com"];
    NSURLProtectionSpace *protSpace = [[NSURLProtectionSpace alloc] initWithHost:url.host
                                                                            port:[url.port integerValue]
                                                                        protocol:url.scheme
                                                                           realm:nil
                                                            authenticationMethod:NSURLAuthenticationMethodHTMLForm];
    return protSpace;
    
}

-(void)viewDidLoad {
    [self.scrollView setContentSize:CGSizeMake(1320,1980)];
    
}

@end
