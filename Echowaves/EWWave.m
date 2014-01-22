//
//  EWWave.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EWWave.h"

@implementation EWWave


+ (NSURLProtectionSpace*) echowavesProtectionSpace {
    NSURL *url = [NSURL URLWithString:@"http://echowaves.com"];
    NSURLProtectionSpace *protSpace = [[NSURLProtectionSpace alloc] initWithHost:url.host
                                                                            port:[url.port integerValue]
                                                                        protocol:url.scheme
                                                                           realm:nil
                                                            authenticationMethod:nil];
    return protSpace;
}


+ (void) storeCredentialForWaveName:(NSString *)waveName withPassword:(NSString *)wavePassword {    NSLog(@"storing credentials %@ : %@", waveName, wavePassword);
    NSURLCredential *credential;
    NSDictionary *credentials;
    credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:EWWave.echowavesProtectionSpace];
    //remove credential
    credential = [credentials.objectEnumerator nextObject];
    [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:EWWave.echowavesProtectionSpace];
    //store new credential
    credential = [NSURLCredential credentialWithUser:waveName password:wavePassword persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:EWWave.echowavesProtectionSpace];

}

+(NSURLCredential*) getStoredCredential {
    //check if credentials are already stored, then show it in the tune in fields
    NSURLCredential *credential;
    NSDictionary *credentials;
    
    credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:EWWave.echowavesProtectionSpace];
    credential = [credentials.objectEnumerator nextObject];
    return credential;
};

@end
