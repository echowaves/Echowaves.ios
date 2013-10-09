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



- (IBAction)startWaving:(UIButton *)sender {
    // perform a basic validation, wave/password non balnk and exist in the server side, and enter a sending loop
    
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"http://echowaves.com/verify_credentials"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"name=%@&pass=%@", _waveName.text, _wavePassword.text];
    
    [request setValue:[NSString
                       stringWithFormat:@"%d", [postString length]]
     
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response
    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"*****************************");
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    NSLog(@"Response ==> %@", result);
    
    if ([urlResponse statusCode] ==200)
    {
        NSLog(@"user name/password found");
        NSLog(@" wave name %@ ", _waveName.text);
        [_waveName setEnabled:NO];
        [_wavePassword setEnabled:NO];
        [sender setEnabled:NO];
        [sender setTitle:[NSString stringWithFormat:@"Currently waving %@", _waveName.text] forState:UIControlStateNormal];
        
        //start a thread that posts the image
        [self performSelectorInBackground:@selector(postLastImage) withObject:nil];
        
        
        
    } else {
        NSLog(@"user name/password not found");
    }
    
    
}

- (void) postLastImage
{
    while(true) {
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
                                         NSError* error = nil;
                                         NSLog(@"%@", [error localizedDescription]);
                                         UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullResolutionImage]];

                                         // post image to echowaves.com
                                         NSLog(@"image %@", latestPhoto.description);
                                         NSLog(@"asset %@", alAsset.description);
                                     }
                                 }];
        }
                             failureBlock: ^(NSError *error) {
                                 // Typically you should handle an error more gracefully than this.
                                 NSLog(@"No groups. %@", error);
                             }];
        
        NSLog(@"sleeping for 2 second...");
        [NSThread sleepForTimeInterval:2.0f];
    } // while YES
    
}

@end
