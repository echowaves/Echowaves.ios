//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EchowavesViewController ()

@end

@implementation EchowavesViewController
static NSString *host = @"http://echowaves.com";
//static NSString *host = @"http://localhost:3000";


- (IBAction)startWaving:(UIButton *)sender {
    if ([self isWaving] == false) {
        
        //wipe out cookies first
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
        for (NSHTTPCookie* cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
        _manager = [AFHTTPRequestOperationManager manager];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        //ideally not going to need the following line, if making a request to json service
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"name": _waveName.text,
                                     @"pass": _wavePassword.text};
        
        [_manager POST:[NSString stringWithFormat:@"%@/login", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //        NSLog(@"response: %@", responseObject);
            NSLog(@"user name/password found");
            NSLog(@"wave name %@ ", _waveName.text);
            
            
            //try to retrieve a cookie
            NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
            if(cookies.count >0) {// this means we are successfully signed in and can start posting images
                // at this point the sign in is successfull, let's disable the UI fields so they can't be changed.
                [_waveName setEnabled:NO];
                [_wavePassword setEnabled:NO];
                [sender setTitle:[NSString stringWithFormat:@"stop waving"] forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor redColor]];
                //let's remember when we started the app, from now on -- send all the pictures
                _lastCheckTime = [NSDate date];
                [self setWaving:true];
                [_appStatus setText:[NSString stringWithFormat:@"Now Waving ..."]];
            } else {
                // a wrong wave, sign in again
                NSLog(@"Wrong wave or password, try again.");
                [_appStatus setText:[NSString stringWithFormat:@"Wrong wave or password, try again..."]];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    } else { // not waiving
        //stop waiving here
        [[NSOperationQueue mainQueue] cancelAllOperations];
        
        [self setWaving:false];
        [_waveName setEnabled:YES];
        [_wavePassword setEnabled:YES];
        [_appStatus setText:[NSString stringWithFormat:@"Stopped Waving."]];
        [sender setTitle:[NSString stringWithFormat:@"start waving"] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor blueColor]];
    }
    ///////////////////////////////////////////////////////////////////////////////////
}


- (BOOL) checkForNewImages
{
        NSLog(@"----------------- Checking images");
        NSMutableArray *imagesToPostOperations = [NSMutableArray array];
        [_appStatus setText:[NSString stringWithFormat:@"Checking for new images ..."]];
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
                    
                    NSTimeInterval timeSinceLastPost = [currentAssetDateTime timeIntervalSinceDate:_lastCheckTime]; // diff
                    
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
                        
                        
                        NSDictionary *parameters = @{@"name": _waveName.text};
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyyMMddHHmmss"];
                        
                        NSData *webUploadData=UIImageJPEGRepresentation(resizedImage, 1.0);
                        NSString *dateString = [formatter stringFromDate:currentAssetDateTime];
                        
                        
                        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/upload", host] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                            [formData appendPartWithFileData:webUploadData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg", dateString] mimeType:@"image/jpeg"];
                        } error:nil];
                                                 

                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

//                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *currentOperation, id responseObject) {
//                            _imageCurrentlyUploading = [UIImageView alloc];
//                            [_imageCurrentlyUploading setImage:resizedImage];
//                        } failure:nil];
                        
                        [imagesToPostOperations addObject:operation];

                        
                        NSLog(@"+++++++++++++++ images to upload while checking %d", imagesToPostOperations.count);
                        
                    } // if timeSinceLastPost
                    
                } else { // here is at the end of the iterating over assets
                    [self postNewImages:imagesToPostOperations];
                    _lastCheckTime = [NSDate date];
                }
            }];
        } failureBlock: ^(NSError *error) {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"+++++++++++++++ No groups. %@", error);
        }];
    
    
    return YES;
}

- (BOOL) postNewImages:(NSMutableArray *)imagesToPostOperations
{
    NSLog(@"----------------- Posting images");
    if([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        NSLog(@"+++++++++++++++networking is reachable -- posting!!!!!!!!!!!!");
        NSLog(@"+++++++++++++++images to upload while posting %d", imagesToPostOperations.count);
        
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:imagesToPostOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
            [_appStatus setText:[NSString stringWithFormat:@"Uploading %d of %d.", numberOfFinishedOperations, totalNumberOfOperations]];
        } completionBlock:^(NSArray *operations) {
            NSLog(@"All operations in batch complete");
            NSLog(@"operations count %d", operations.count);
            [imagesToPostOperations removeAllObjects];
            [_appStatus setText:@"Nothing to upload."];

        }];
        [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
        
    } else {
        NSLog(@"+++++++++++++++networking is not reachable -- not !!!!!!!!!! posting!!!!!!!!!!!!");
        [_appStatus setText:@"Network is not reachable, try again later."];
        return NO;
    }
    NSLog(@"+++++++++++++++at the end of posting cycle, imagesToUpload %d",     imagesToPostOperations.count);

    return YES;
}

@end
