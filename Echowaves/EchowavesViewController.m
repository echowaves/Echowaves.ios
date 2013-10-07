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
        
        
        // here is a core loop that troes to identify the new images and upload them in real time.
        while(true) {
            
            [self performSelectorInBackground:@selector(postLastImage) withObject:nil];
            NSLog(@"sleeping for 3 second...");
            [NSThread sleepForTimeInterval:0.1f];
        } // while YES
        
        
        
    } else {
        NSLog(@"user name/password not found");
    }
    
    
}

- (void) postLastImage
{
    NSMutableArray *assets = [[NSMutableArray alloc]init];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup   *group,  BOOL *stop){
        
        if(group != NULL){
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                
                if(result != NULL){
                    [assets addObject:result];
                    NSLog(@"added picture %@", result);
                }else NSLog(@"NO photo");;
            }];
        }
    }
                         failureBlock:^(NSError *error){NSLog(@"Error");}];
    
    
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    
//    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
//    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        
//        // Within the group enumeration block, filter to enumerate just videos.
//        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//        
//        // For this example, we're only interested in the first item.
//        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)] //change this for latest photo
//                                options:0
//                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
//                                 
//                                 // The end of the enumeration is signaled by asset == nil.
//                                 if (alAsset) {
//                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
//                                     NSURL *url = [representation url];
//                                     //ALAsset *avAsset = [ALAsset URL //[ALAsset URLAssetWithURL:url options:nil];
//                                     UIImage *latestPhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//                                     
//                                     // Do something interesting with the AV asset.
//                                     NSLog(@"image %@", latestPhoto.description);
//                                 }
//                             }];
//    }
//                         failureBlock: ^(NSError *error) {
//                             // Typically you should handle an error more gracefully than this.
//                             NSLog(@"No groups");
//                         }];
}

@end
