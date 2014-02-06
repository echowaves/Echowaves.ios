//
//  EWImage.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDataModel.h"

//#import "EWWave.h"
@interface EWImage : EWDataModel

+ (void) checkForNewImagesToPostToWave:(NSString*) waveName
                        whenImageFound:(void (^)(UIImage* image, NSDate* imageDate))imageFoundBlock
                      whenCheckingDone:(void (^)(void)) checkCompleteBlock
                             whenError:(void (^)(NSError *error)) failureBlock;

+ (AFHTTPRequestOperation*) createPostOperationFromImage:(UIImage *) image
                                               imageDate:(NSDate *) imageDate
                                             forWaveName:(NSString *) waveName;

+ (void) postAllNewImages:(NSMutableArray *)imagesToPostOperations;

+ (void) getAllImagesForWave:(NSString*) waveName
                     success:(void (^)(NSArray *waveImages))success
                     failure:(void (^)(NSError *error))failure;


@end
