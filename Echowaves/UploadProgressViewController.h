//
//  UploadProgressViewController.h
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperation.h"
#import "EchowavesAppDelegate.h"
#import "EchowavesImagePickerController.h"


@interface UploadProgressViewController : UIViewController

@property (nonatomic) BOOL deactivated;

@property (weak, nonatomic) IBOutlet UIButton *cancelUpload;

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressBar;


@property (weak, nonatomic) IBOutlet UILabel *imagesToUpload;

@property (weak, nonatomic) IBOutlet UIImageView *currentlyUploadingImage;


@property (weak, nonatomic) AFHTTPRequestOperation *currentUploadOperation;


- (void) checkForNewAssets: (long) assetsCount;

- (void) comeBack;

@end
