//
//  SignInViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController


- (IBAction)tuneIn:(UIButton *) sender {
    
    NSURLCredential *credential;
    credential = [NSURLCredential credentialWithUser:[self.waveName text] password:[self.wavePassowrd text] persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:SignInViewController.echowavesProtectionSpace];
    
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

@end
