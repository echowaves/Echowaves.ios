//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface EchowavesViewController ()

@end

@implementation EchowavesViewController

//static NSString *host = @"http://echowaves.com";
static NSString *host = @"http://localhost:3000";
AFHTTPRequestOperationManager *manager;

- (IBAction)startWaving:(UIButton *)sender {
    //wipe out cookies first
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:host]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    // perform authentication, wave/password non balnk and exist in the server side, and enter a sending loop
    manager = [AFHTTPRequestOperationManager manager];
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
            //        [_waveName setEnabled:NO];
            //        [_wavePassword setEnabled:NO];
            //        [sender setEnabled:NO];
            //        [sender setTitle:[NSString stringWithFormat:@"Currently waving %@", _waveName.text] forState:UIControlStateNormal];

            //start a thread that posts the image
            [self performSelectorInBackground:@selector(postLastImage) withObject:nil];
        } else {
            // a wrong login, sign in again
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    ///////////////////////////////////////////////////////////////////////////////////
}

- (void) postLastImage
{
    //    while(true) {
    //http://iphonedevsdk.com/forum/iphone-sdk-development/94700-directly-access-latest-photo-from-saved-photos-camera-roll.html
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just videos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        // For this example, we're only interested in the first item.
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)] //change this for latest photo
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     //                                         NSError* error = nil;
                                     //                                         NSLog(@"%@", [error localizedDescription]);
                                     //                                         UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                                     
                                     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                     // post image to echowaves.com
                                     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                     
                                     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                     [formatter setDateFormat:@"yyyyMMddHHmmss"];
                                     NSString *dateString = [formatter stringFromDate:[NSDate date]];
                                     
                                     NSDictionary *parameters = @{@"name": _waveName.text};//,
//                                                                  @"pass": _wavePassword.text};
//                                     NSURL *filePath = [representation url];
                                     
                                     UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                                     NSData *webUploadData=UIImageJPEGRepresentation(copyOfOriginalImage, 1.0);

                                     [manager POST:[NSString stringWithFormat:@"%@/upload", host] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                         [formData appendPartWithFileURL:filePath name:@"file" error:nil];
                                         [formData appendPartWithFileData:webUploadData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg", dateString] mimeType:@"image/jpeg"];
                                     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success posting image");
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Error posting image: %@", error);
                                     }];
                                     
                                     
                                     
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
    
    NSLog(@"sleeping for 2 second...");
    [NSThread sleepForTimeInterval:2.0f];
    //    } // while YES
    
}

@end
