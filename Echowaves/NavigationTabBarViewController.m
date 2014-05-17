//
//  NavigationTabBarViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/25/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "NavigationTabBarViewController.h"
#import "DetailedImageViewController.h"

@implementation NavigationTabBarViewController

- (IBAction)takePicture:(id)sender {
    
    NSLog(@"taking picture");
    APP_DELEGATE.wavingViewController.waving.on = true;
    
    [APP_DELEGATE.wavingViewController takepicture];
}

- (IBAction)pushUpload:(id)sender {
    NSLog(@"pushing upload");
    [APP_DELEGATE checkForUpload];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    if([APP_DELEGATE shareActionToken]) {
    
       
       [EWImage retreiveImageByToken:[APP_DELEGATE shareActionToken]
                             success:^(NSString *imageName, NSString *waveName) {
                                 
                                 //                              [EWImage showAlertWithMessage:[NSString stringWithFormat:@"%@/img/%@/%@", EWAWSBucket, waveName, imageName ] FromSender:nil];
                                 
                                 
                                 [EWImage loadImageFromUrl:[NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWAWSBucket, waveName, imageName ]
                                                   success:^(UIImage *image) {

                                                       DetailedImageViewController *detailedImageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImageView"];
                                                       
                                                       detailedImageViewController.imageName = imageName;
                                                       detailedImageViewController.waveName = waveName;
                                                       
                                                       detailedImageViewController.image = image;                                                       

                                                       [self.navigationController pushViewController:detailedImageViewController animated:YES];
                                                       
                                                       APP_DELEGATE.shareActionToken = nil;//release the token
                                                       
                                                   }
                                                   failure:^(NSError *error) {
                                                       [EWImage showAlertWithMessage:error.description FromSender:nil];
                                                   }
                                                  progress:nil];

                                 
                                 
                                 
                             } failure:^(NSError *error) {
                                 //                              [EWImage showAlertWithMessage:[error description] FromSender:nil];
                                 [EWImage showAlertWithMessage:@"Token expired..." FromSender:nil];
                             }];

    }
}

@end
