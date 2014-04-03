//
//  UploadProgressViewController.h
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EchowavesAppDelegate.h"
#import "EchowavesImagePickerController.h"

@interface UploadProgressViewController : EchowavesImagePickerController<EchowavesImagePickerControllerProtocol>

@property (strong, nonatomic) IBOutlet UIButton *cancelUpload;

@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgressBar;


@property (strong, nonatomic) IBOutlet UILabel *imagesToUpload;

@property (strong, nonatomic) IBOutlet UIImageView *currentlyUploadingImage;



@property (weak, nonatomic) AFHTTPRequestOperation *currentUploadOperation;

- (void) checkForNewImages;

@end
