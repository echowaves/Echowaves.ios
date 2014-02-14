//
//  EWImage.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

@import AssetsLibrary;

#import "EWImage.h"

@implementation EWImage

+ (void) checkForNewImagesToPostToWave:(NSString*) waveName
                        whenImageFound:(void (^)(UIImage* image, NSDate* imageDate))imageFoundBlock
                      whenCheckingDone:(void (^)(void)) checkCompleteBlock
                             whenError:(void (^)(NSError *error)) failureBlock
{
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
                
                NSTimeInterval timeSinceLastPost =
                [currentAssetDateTime timeIntervalSinceDate:(NSDate*)[USER_DEFAULTS objectForKey:@"lastCheckTime"]]; // diff
                
                if(timeSinceLastPost > 0.0) {//this means, found an image that was not posted
                    //first lets add the image to a collection, we will process this collection later.
                    
                    NSLog(@"found image that was posted %f seconds since last check", timeSinceLastPost);
                    
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // post image to echowaves.com
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    UIImageOrientation orientation = UIImageOrientationUp;
                    NSNumber* orientationValue = [alAsset valueForProperty:@"ALAssetPropertyOrientation"];
                    if (orientationValue != nil) {
                        orientation = [orientationValue intValue];
                    }
                    
                    UIImage* orientedImage = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                                 scale:1.0 orientation:orientation];
                    
                    CGSize newSize = orientedImage.size;
                    newSize.height = newSize.height / 2.0;
                    newSize.width = newSize.width / 2.0;
                    
                    UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
                    [orientedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                    //image is the original UIImage
                    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    imageFoundBlock(resizedImage, currentAssetDateTime);
                    
                    
                } // if timeSinceLastPost
                
            } else { // here is at the end of the iterating over assets
                [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
                checkCompleteBlock();
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"+++++++++++++++ No groups. %@", error);
        failureBlock(error);
    }];
}

+ (AFHTTPRequestOperation*) createPostOperationFromImage:(UIImage *) image
                                               imageDate:(NSDate *) imageDate
                                             forWaveName:(NSString *) waveName
{
    NSDictionary *parameters = @{@"name": waveName};
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSSS"];
    
    NSData *webUploadData=UIImageJPEGRepresentation(image, 1.0);
    NSString *dateString = [formatter stringFromDate:imageDate];
    
    
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
    
    return operation;
}

+ (void) postAllNewImages:(NSMutableArray *)imagesToPostOperations
{
    NSLog(@"----------------- Posting images");
    
    for(AFHTTPRequestOperation *operation in imagesToPostOperations) {
        [APP_DELEGATE.networkQueue addOperation:operation];
    }
}



+ (void) getAllImagesForWave:(NSString*) waveName
                     success:(void (^)(NSArray *waveImages))success
                     failure:(void (^)(NSError *error))failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    [manager GET:[NSString stringWithFormat:@"%@/wave.json", EWHost]
      parameters:nil
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

+(void) deleteImage:(NSString *)imageName
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"name": imageName};
    
    [manager POST:[NSString stringWithFormat:@"%@/delete-image.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);
    }];

}


@end
