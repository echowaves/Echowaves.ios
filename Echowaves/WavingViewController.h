//
//  EchowavesViewController.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "EchowavesAppDelegate.h"
#import "EchowavesImagePickerController.h"

@interface WavingViewController : EchowavesImagePickerController<EchowavesImagePickerControllerProtocol>


@property (nonatomic) IBOutlet UISwitch *waving;

@property (strong, nonatomic) IBOutlet UILabel *appStatus;

@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgressBar;

@property (strong, nonatomic) IBOutlet UIButton *cancelUpload;

@property (strong, nonatomic) IBOutlet UILabel *imagesToUpload;

@property (strong, nonatomic) IBOutlet UIImageView *currentlyUploadingImage;

@property (weak, nonatomic) AFHTTPRequestOperation *currentUploadOperation;

- (void) checkForNewImages;


@end
//nsuserdefaults
//http://stackoverflow.com/questions/8565087/afnetworking-and-cookies/17997943#17997943