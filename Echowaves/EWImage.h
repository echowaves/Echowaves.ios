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
                      whenCheckingDone:(void (^)(NSArray* assets)) checkCompleteBlock
                             whenError:(void (^)(NSError *error)) failureBlock;


+ (void) operationFromAsset:(ALAsset *)asset
       forWaveName:(NSString *) waveName
      success:(void (^)(AFHTTPRequestOperation* operation, UIImage* image, NSDate* currentAssetDateTime))success;

+ (void) getAllImagesForWave:(NSString*) waveName
                     success:(void (^)(NSArray *waveImages))success
                     failure:(void (^)(NSError *error))failure;

//+ (void) loadImageFromUrl:(NSString*) url
//                  success:(void (^)(UIImage *image))success
//                  failure:(void (^)(NSError *error))failure
//                 progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

+ (void) loadFullImage:(NSString*) imageName
               forWave:(NSString*) waveName
                  success:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure
                 progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

+ (void) loadThumbImage:(NSString*) imageName
                forWave:(NSString*) waveName
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure;
//               progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;


+(void) deleteImage:(NSString *)imageName
             inWave:(NSString *)waveName
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;

+(void) saveImageToAssetLibrary:(UIImage*) image
                        success:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure;

+(void) shareImage:(NSString *)imageName
             inWave:(NSString *)waveName
            success:(void (^)(NSString* token))success
            failure:(void (^)(NSError *error))failure;

+(void) retreiveImageByToken:(NSString *) token
           success:(void (^)(NSString* imageName, NSString* waveName))success
           failure:(void (^)(NSError *error))failure;

//find index of an image in the all images array by image name and wave name
+(long)imageIndexFromImageName:(NSString *) imageName
                      waveName:(NSString *) waveName
                    waveImages:(NSArray *) waveImages;


@end
