//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface EchowavesViewController ()

@end

@implementation EchowavesViewController
static NSString *host = @"http://echowaves.com";
//static NSString *host = @"http://localhost:3000";
AFHTTPRequestOperationManager *manager;
NSDate *lastCheckTime;
int imageCount = 0;

- (IBAction)startWaving:(UIButton *)sender {
    if ([self isWaving] == false) {
    //wipe out cookies first
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    manager = [AFHTTPRequestOperationManager manager];
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
            // at this point the sign in is successfull, let's disable the UI fields so they can't be changed.
            [_waveName setEnabled:NO];
            [_wavePassword setEnabled:NO];
            [sender setTitle:[NSString stringWithFormat:@"stop waving"] forState:UIControlStateNormal];
            [sender setBackgroundColor:[UIColor redColor]];
            //let's remember when we started the app, from now on -- send all the pictures
            lastCheckTime = [NSDate date];
            [self setWaving:true];
            [_appStatus setText:[NSString stringWithFormat:@"started waving..."]];
        } else {
            // a wrong login, sign in again
            NSLog(@"wrong login, try again");
            [_appStatus setText:[NSString stringWithFormat:@"wrong login, try again..."]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    } else {
        //stop waiving here
        [self setWaving:false];
        [_waveName setEnabled:YES];
        [_wavePassword setEnabled:YES];
        [_appStatus setText:[NSString stringWithFormat:@"waving stopped"]];
        [sender setTitle:[NSString stringWithFormat:@"start waving"] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor blueColor]];
    }
    ///////////////////////////////////////////////////////////////////////////////////
}


- (BOOL) postLastImages
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        NSLog(@"networking is reachable -- posting!!!!!!!!!!!!");
        __block BOOL imageFound = NO;
        //http://iphonedevsdk.com/forum/iphone-sdk-development/94700-directly-access-latest-photo-from-saved-photos-camera-roll.html
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // Within the group enumeration block, filter to enumerate just videos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // iterating over all assets
            [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                __block BOOL imageFound = NO;
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset)
                {
                    NSDate *currentAssetDateTime = [alAsset valueForProperty:ALAssetPropertyDate];
                    
                    NSTimeInterval timeSinceLastPost =
                    [currentAssetDateTime timeIntervalSinceDate:lastCheckTime]; // diff
                    
                    if(timeSinceLastPost > 0.0) {//this means, found an image that was not posted
                        imageFound = YES;
                        NSLog(@"found image that was posted %f seconds since last check", timeSinceLastPost);
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *dateString = [formatter stringFromDate:currentAssetDateTime];
                        
                        NSDictionary *parameters = @{@"name": _waveName.text};//,
                        
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
                        
                        
                        
                        NSData *webUploadData=UIImageJPEGRepresentation(resizedImage, 1.0);
                        [_appStatus setText:[NSString stringWithFormat:@"uploading image %d", imageCount]];
                        
                        [manager POST:[NSString stringWithFormat:@"%@/upload", host] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            [formData appendPartWithFileData:webUploadData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg", dateString] mimeType:@"image/jpeg"];
                            
                        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            //reset the date here
                            lastCheckTime = currentAssetDateTime;
                            [_appStatus setText:[NSString stringWithFormat:@"finished uploading image %d", imageCount++]];
                            NSLog(@"Success posting image");
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [_appStatus setText:[NSString stringWithFormat:@"error uploading: %@", error]];
                            NSLog(@"Error posting image: %@", error);
                        }];
                        
                    } // if timeSinceLastPost
                    
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    //                                         NSLog(@"image %@", latestPhoto.description);
                    //                                         NSLog(@"asset %@", alAsset.description);
                }
            }];
        }
                             failureBlock: ^(NSError *error) {
                                 // Typically you should handle an error more gracefully than this.
                                 NSLog(@"No groups. %@", error);
                             }];
        return imageFound;
    }
    NSLog(@"networking is not reachable -- not !!!!!!!!!! posting!!!!!!!!!!!!");

    return NO;
}

@end
