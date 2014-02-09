//
//  EWBlend.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EWBlend.h"

@implementation EWBlend

+(void) autoCompleteFor:(NSString *)waveName
                success:(void (^)(NSArray *waveNames))success
                failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"term": waveName};

    
    [manager GET:[NSString stringWithFormat:@"%@/autocomplete-wave-name.json", EWHost]
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success((NSArray*)responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             failure(error);
         }];
}

+(void) requestBlendingWith:(NSString *)waveName
                    success:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"wave_name": waveName};
    
    [manager POST:[NSString stringWithFormat:@"%@/request-blending.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);        
    }];
}

@end
