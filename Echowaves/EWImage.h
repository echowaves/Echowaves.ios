//
//  EWImage.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

@import AssetsLibrary;

#import <Foundation/Foundation.h>
#import "EWDataModel.h"

//#import "EWWave.h"
@interface EWImage : EWDataModel

+ (void) checkForNewAssetsToPostToWave:(NSString*) waveName
                        whenAssetFound:(void (^)(ALAsset* alAsset))assetFoundBlock
                      whenCheckingDone:(void (^)(void)) checkCompleteBlock
                             whenError:(void (^)(NSError *error)) failureBlock;


+ (void) postAllNewAssets:(NSMutableArray *)assetsToPostOperations
              forWaveName:(NSString *) waveName
           postingAsset:(void (^)(AFHTTPRequestOperation* operation, UIImage* image, NSDate* currentAssetDateTime))postingAssetBlock
          postingComplete:(void (^)(void)) postingCompleteBlock
                whenError:(void (^)(NSError *error)) failureBlock;


+ (void) getAllImagesForWave:(NSString*) waveName
                     success:(void (^)(NSArray *waveImages))success
                     failure:(void (^)(NSError *error))failure;

+ (void) loadImageFromUrl:(NSString*) url
                  success:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure
                 progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

+(void) deleteImage:(NSString *)imageName
             inWave:(NSString *)waveName
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;

+(void) saveImageToAssetLibrary:(UIImage*) image
                        success:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure;
;

@end
