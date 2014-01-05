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
        if(_lastCheckTime == nil) {
            _lastCheckTime = [NSDate date];
        }
        [self tuneIn];
        //let's remember when we started the app, from now on -- send all the pictures
    } else { // not waiving
        [self tuneOut];
        //stop waiving here
        [_appStatus setText:[NSString stringWithFormat:@"Waving Stopped."]];
        _lastCheckTime = nil;
    }
    ///////////////////////////////////////////////////////////////////////////////////
}

- (void) tuneIn
{
    [self setWaving:false];
    
    //wipe out cookies first
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"name": _waveName.text,
                                 @"pass": _wavePassword.text};
    
    [manager POST:[NSString stringWithFormat:@"%@/login", host] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"response: %@", responseObject);
        NSLog(@"user name/password found");
        NSLog(@"wave name %@ ", _waveName.text);
        
        //try to retrieve a cookie
        NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
        if(cookies.count >0) {// this means we are successfully signed in and can start posting images
            [self setWaving:true];
            [_appStatus setText:[NSString stringWithFormat:@"Now Waving ..."]];
            [_startButton setTitle:[NSString stringWithFormat:@"stop waving"] forState:UIControlStateNormal];
            [_startButton setBackgroundColor:[UIColor redColor]];
            [_waveName setEnabled:NO];
            [_wavePassword setEnabled:NO];
        } else {
            // a wrong wave, sign in again
            NSLog(@"Wrong wave or password, try again.");
            [self setWaving:false];
            [_appStatus setText:[NSString stringWithFormat:@"Wrong wave or password, try again..."]];
            [_startButton setTitle:[NSString stringWithFormat:@"start waving"] forState:UIControlStateNormal];
            [_startButton setBackgroundColor:[UIColor blueColor]];
            [_waveName setEnabled:YES];
            [_wavePassword setEnabled:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self setWaving:false];
        [_appStatus setText:[NSString stringWithFormat:@"Error, try again..."]];
        [_startButton setTitle:[NSString stringWithFormat:@"start waving"] forState:UIControlStateNormal];
        [_startButton setBackgroundColor:[UIColor blueColor]];
        [_waveName setEnabled:YES];
        [_wavePassword setEnabled:YES];
    }];
    
}

- (void) tuneOut
{
    [self setWaving:false];
    [_appStatus setText:[NSString stringWithFormat:@"Waving stopped..."]];
    [_startButton setTitle:[NSString stringWithFormat:@"start waving"] forState:UIControlStateNormal];
    [_startButton setBackgroundColor:[UIColor blueColor]];
    [_waveName setEnabled:YES];
    [_wavePassword setEnabled:YES];
    
}

- (BOOL) checkForNewImages
{
    NSLog(@"----------------- Checking images");    
    NSMutableArray *imagesToPostOperations = [NSMutableArray array];
    [_appStatus setText:[NSString stringWithFormat:@"Checking for new pictures ..."]];
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
                    [formatter setDateFormat:@"yyyyMMddHHmmssSSSS"];
                    
                    NSData *webUploadData=UIImageJPEGRepresentation(resizedImage, 1.0);
                    NSString *dateString = [formatter stringFromDate:currentAssetDateTime];
                    
                    
                    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/upload", host] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                        [formData appendPartWithFileData:webUploadData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg", dateString] mimeType:@"image/jpeg"];
                    } error:nil];
                    
                    
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    
                    //                        [operation setCredential:[NSURLCredential credentialWithUser:_waveName.text password:_wavePassword.text persistence:NSURLCredentialPersistenceForSession]];
                    
                    
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
        [_appStatus setText:[NSString stringWithFormat:@"Uploading pictures..."]];
        
        for(AFHTTPRequestOperation *operation in imagesToPostOperations) {
            [self.networkQueue addOperation:operation];
        }
        
        
    } else {
        NSLog(@"+++++++++++++++networking is not reachable -- not !!!!!!!!!! posting!!!!!!!!!!!!");
        return NO;
    }
    NSLog(@"+++++++++++++++at the end of posting cycle, imagesToUpload %d",     imagesToPostOperations.count);
    
    return YES;
}

@end
