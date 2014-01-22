//
//  EWWave.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWWave : NSObject

+ (NSURLProtectionSpace*) echowavesProtectionSpace;
+ (void) storeCredentialForWaveName:(NSString *)waveName withPassword:(NSString *)wavePassword;
+ (NSURLCredential*) getStoredCredential;


@end
