//
//  EWImage.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EWImage.h"

@implementation EWImage

+ (void) checkForNewAssetsToPostToWave:(void (^)(NSArray* assets)) checkCompleteBlock
                             whenError:(void (^)(NSError *error)) failureBlock
{
    NSMutableArray* assets = [NSMutableArray array];
    NSLog(@"----------------- Checking images");
    //find if there are any new images to post
    //http://iphonedevsdk.com/forum/iphone-sdk-development/94700-directly-access-latest-photo-from-saved-photos-camera-roll.html
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just videos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // iterating over all assets
        [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset)
            {
                NSDate *currentAssetDateTime = [alAsset valueForProperty:ALAssetPropertyDate];
                
                if([USER_DEFAULTS objectForKey:@"lastCheckTime"] == nil) {
                    [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
                    [USER_DEFAULTS synchronize];
                }
                
                NSTimeInterval timeSinceLastPost =
                [currentAssetDateTime timeIntervalSinceDate:(NSDate*)[USER_DEFAULTS objectForKey:@"lastCheckTime"]]; // diff
                
                if(timeSinceLastPost > 0.0) {//this means, found an image that was not posted
                    //first lets add the image to a collection, we will process this collection later.
                    
//                    NSLog(@"found image that was posted %f seconds since last check", timeSinceLastPost);
                    
                    [assets addObject:alAsset];
                    
                } // if timeSinceLastPost
                
            } else { // here is at the end of the iterating over assets
//                [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
//                [USER_DEFAULTS synchronize];
                checkCompleteBlock(assets);
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"+++++++++++++++ No groups. %@", error);
        failureBlock(error);
    }];
}



+ (void) operationFromAsset:(ALAsset *)asset
              forWaveName:(NSString *) waveName
             success:(void (^)(AFHTTPRequestOperation* operation, UIImage* image, NSDate* currentAssetDateTime))success
{
    NSLog(@"----------------- Posting asset");
    
        NSDate *currentAssetDateTime = [asset valueForProperty:ALAssetPropertyDate];
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // post image to echowaves.com
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        UIImage* orientedImage = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                     scale:1.0 orientation:orientation];
        
        CGSize newSize = orientedImage.size;
        newSize.height = newSize.height / 1.0;
        newSize.width = newSize.width / 1.0;
        
        UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
        [orientedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        //image is the original UIImage
        UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSDictionary *parameters = @{@"name": waveName};
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmssSSSS"];
        
        NSData *webUploadData=UIImageJPEGRepresentation(resizedImage, 1.0);
        NSString *dateString = [formatter stringFromDate:currentAssetDateTime];
        
        
        NSURLRequest *request =
        [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                   URLString:[NSString stringWithFormat:@"%@/upload", EWHost]
                                                                  parameters:parameters
                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                       [formData appendPartWithFileData:webUploadData
                                                                                   name:@"file"
                                                                               fileName:[NSString stringWithFormat:@"%@.jpg", dateString]
                                                                               mimeType:@"image/jpeg"];
                                                   }
                                                                       error:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        success(operation, resizedImage, currentAssetDateTime);
    
}



+ (void) getAllImagesForWave:(NSString*) waveName
                     success:(void (^)(NSArray *waveImages))success
                     failure:(void (^)(NSError *error))failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"wave_name": waveName};

    
    [manager GET:[NSString stringWithFormat:@"%@/wave.json", EWHost]
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success((NSArray*)responseObject);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failure(error);
         }];
};

+ (void) loadImageFromUrl:(NSString*) url
                  success:(void (^)(UIImage *image))success
                  failure:(void (^)(NSError *error))failure
                 progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    AFHTTPRequestOperation *imgOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    imgOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [imgOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response: %@", responseObject);
        success(responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failure(error);
    }];
    if(progress) {
        [imgOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
        }];
    }
    [imgOperation start];
}


+ (void) loadFullImage:(NSString*) imageName
               forWave:(NSString*) waveName
               success:(void (^)(UIImage *image))success
               failure:(void (^)(NSError *error))failure
              progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/%@", EWAWSBucket, waveName, imageName];
    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
                          success(image);
                      }
                      failure:^(NSError *error) {
                          failure(error);
                      }
                     progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                         progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                     }];
    
};

+ (void) loadThumbImage:(NSString*) imageName
                forWave:(NSString*) waveName
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure {
//               progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    NSString* thumbImageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWAWSBucket, waveName, imageName];
    [EWImage loadImageFromUrl:thumbImageUrl
                      success:^(UIImage *image) {
                          success(image);
                      }
                      failure:^(NSError *error) {
                          failure(error);
                      }
                     progress:nil];
};


+(void) deleteImage:(NSString *)imageName
             inWave:(NSString *)waveName
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"image_name": imageName,
                                 @"wave_name": waveName};
    
    [manager POST:[NSString stringWithFormat:@"%@/delete-image.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);
    }];

}

+(void) saveImageToAssetLibrary:(UIImage*) image
                        success:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure
{
    CGImageRef img = [image CGImage];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library writeImageToSavedPhotosAlbum:img
                              orientation:ALAssetOrientationUp
                          completionBlock:^(NSURL* assetURL, NSError* error) {
                              if (error.code == 0) {
                                  NSLog(@"saved image completed:\nurl: %@", assetURL);
                                  [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
                                  [USER_DEFAULTS synchronize];

                                  success();
                              }
                              else {
                                  NSLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                  failure(error);
                              }
                          }];
    
}


+(void) shareImage:(NSString *)imageName
            inWave:(NSString *)waveName
           success:(void (^)(NSString* token))success
           failure:(void (^)(NSError *error))failure {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"image_name": imageName,
                                 @"wave_name": waveName};
    
    [manager POST:[NSString stringWithFormat:@"%@/share-image.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString* token = [(NSDictionary*)responseObject objectForKey:@"token"];
        NSLog(@",,,,,,,,,,,,,,,,,,token %@", token);
        success(token);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);
    }];
    
    
}

+(void) retreiveImageByToken:(NSString *) token
                     success:(void (^)(NSString* imageName, NSString* waveName))success
                     failure:(void (^)(NSError *error))failure {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"token": token};
    
    [manager POST:[NSString stringWithFormat:@"%@/image-by-token.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* imageName = [(NSDictionary*)responseObject objectForKey:@"name"];
        NSString* waveName = [(NSDictionary*)responseObject objectForKey:@"name_2"];
        success(imageName, waveName);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);
    }];

}

//+(long)imageIndexFromImageName:(NSString *) imageName
//                      waveName:(NSString *) waveName
//                    waveImages:(NSArray *) waveImages {
//    
//    for (long i = 0; i < [waveImages count]; i++) {
//        NSDictionary *image = [waveImages objectAtIndex:i];
//        NSString* imageNameFromArray = [image objectForKey:@"name"];
//        NSString* waveNameFromArray = [image objectForKey:@"name_2"];
//        if([imageName isEqual:imageNameFromArray] && [waveName isEqual:waveNameFromArray]){
//            return i;
//        }        
//    }
//    
//    return -1;
//}

@end
