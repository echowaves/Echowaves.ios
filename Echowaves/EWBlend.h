//
//  EWBlend.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDataModel.h"

@interface EWBlend : EWDataModel

//+(void) autoCompleteFor:(NSString *) waveName
//                success:(void (^)(NSArray *waveNames))success
//                failure:(void (^)(NSError *error))failure;

//+(void) requestBlendingWith:(NSString *)waveName
//                    success:(void (^)(void))success
//                    failure:(void (^)(NSError *error))failure;
//+(void) confirmBlendingWith:(NSString *)waveName
//                    success:(void (^)(void))success
//                    failure:(void (^)(NSError *error))failure;
+(void) unblendFrom:(NSString *)waveName
        currentWave:(NSString *)currentWave
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;



//
//+(void) getRequestedBlends:(void (^)(NSArray *waveNames))success
//                   failure:(void (^)(NSError *error))failure;
//+(void) getUnconfirmedBlends:(void (^)(NSArray *waveNames))success
//                     failure:(void (^)(NSError *error))failure;
+(void) getBlendedWith:(void (^)(NSArray *waveNames))success
               failure:(void (^)(NSError *error))failure;


+(void) acceptBlending:(NSString *)origMyWaveName
            myWaveName:(NSString *)myWaveName
        friendWaveName:(NSString *)frindWaveName
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;


@end
