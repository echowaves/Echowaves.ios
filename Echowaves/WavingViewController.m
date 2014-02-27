//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "WavingViewController.h"
#import "EWWave.h"
#import "EWImage.h"

//@interface WavingViewController ()
//
//@end
//

@implementation WavingViewController


- (IBAction)wavingChanged:(id)sender {
    NSLog(@"=======waving changed to: %d", self.waving.on);
    
    if(self.waving.on) {
        NSLog(@"======== reset lastCheckTime");
        [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
        [self appStatus].text = @"Use iPhone cam, then come back to EW...";
    } else {
        [self appStatus].text = @"No iPhone images will be uploaded...";
    }
    
    [USER_DEFAULTS setBool:self.waving.on forKey:@"waving"];
    [USER_DEFAULTS synchronize];
}

- (IBAction)cancelingCurrentUploadOperation:(id)sender {
    [self.currentUploadOperation cancel];
    [self cleanupCurrentUploadView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self cleanupCurrentUploadView];
    NSLog(@"#### WavingViewController viewDidLoad ");
    APP_DELEGATE.wavingViewController = self;
    
    NSLog(@"=======waving initializing was %d changed to: %d", self.waving.on, [USER_DEFAULTS boolForKey:@"waving"]);
    self.waving.on = [USER_DEFAULTS boolForKey:@"waving"];
    //    [self appStatus].text = @"Use iPhone camera now, come back to EW to start upload";
    //    [self imagesToUpload].hidden = TRUE;
    [self currentlyUploadingImage].contentMode = UIViewContentModeScaleAspectFit;
    self.uploadProgressBar.progress = 0.0;
    
    [self checkForNewImages];
}

- (void) checkForNewImages {
    
    //try to sign in to see if connection is awailable
    NSURLCredential *credential = [EWWave getStoredCredential];
    if(credential) {
        NSLog(@"User %@ already connected with password.", credential.user);
        
        [EWWave tuneInWithName:credential.user
                   andPassword:credential.password
                       success:^(NSString *waveName) {
                           NSLog(@"successsfully signed in");
                           NSMutableArray *imagesToPostOperations = [NSMutableArray array];
                           [self appStatus].text = @"Checking for new images...";
                           
                           if (self.waving.on) {
                               [EWImage checkForNewImagesToPostToWave:waveName
                                                       whenImageFound:^(UIImage *image, NSDate *imageDate) {
                                                           
                                                           AFHTTPRequestOperation* _operation = [EWImage createPostOperationFromImage:image
                                                                                                                            imageDate:imageDate
                                                                                                                          forWaveName:waveName];
                                                           __weak AFHTTPRequestOperation *operation = _operation;
                                                           
                                                           [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                                                               long long totalBytesWritten,
                                                                                               long long totalBytesExpectedToWrite) {
                                                               if(!self.currentlyUploadingImage.image) { // beginning new upload operation here
                                                                   self.cancelUpload.hidden = FALSE;
                                                                   
                                                                   self.currentUploadOperation = operation;
                                                                   self.currentlyUploadingImage.image = image;
                                                                   self.currentlyUploadingImage.hidden = FALSE;
                                                                   [self imagesToUpload].text = [NSString stringWithFormat:@"%d", APP_DELEGATE.networkQueue.operationCount];
                                                                   //                                            [self imagesToUpload].hidden = FALSE;
                                                               }
                                                               
                                                               self.uploadProgressBar.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
                                                               //                                        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
                                                               //                                        NSLog(@"progress %@", [[NSNumber numberWithDouble:((float)totalBytesWritten/totalBytesExpectedToWrite)] stringValue]);
                                                               
                                                           }];
                                                           [operation setCompletionBlock:^{
                                                               [self cleanupCurrentUploadView];
                                                               [EWWave sendPushNotifyForWave:waveName
                                                                                       badge:imagesToPostOperations.count
                                                                                     success:^{
                                                                                         NSLog(@"!!!!!!!!!!!!!!!pushed successfully");
                                                                                     }
                                                                                     failure:^(NSError *error) {
                                                                                         NSLog(@"this error should never happen %@", error.description);
                                                                                     }];
                                                           }];
                                                           
                                                           NSLog(@"@@@@@@@@@@@@@ image found %@", imageDate.description);
                                                           
                                                           [imagesToPostOperations addObject:operation];
                                                           
                                                           [self imagesToUpload].text = [NSString stringWithFormat:@"%d", imagesToPostOperations.count];
                                                           //the following like is needed to force update the label
                                                           [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
                                                           
                                                           
                                                           NSLog(@"@@@@@@@@@@@@@@@@ images to post %d", imagesToPostOperations.count);
                                                           
                                                       }
                                                     whenCheckingDone:^{
                                                         [self appStatus].text = @"Use iPhone cam, then come back to EW...";
                                                         
                                                         //                                  [self appStatus].text = @"uploading now";
                                                         //                                  [self imagesToUpload].hidden = TRUE;
                                                         [EWImage postAllNewImages:imagesToPostOperations];
                                                     }
                                                            whenError:^(NSError *error) {
                                                                NSLog(@"this error should never happen %@", error.description);
                                                                [self appStatus].text = error.description;
                                                            }];
                           }
                           
                       }
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:self];
                       }];
        
        
        
    } else { // credentials are not set, can't really ever happen, something is really wrong here
        NSLog(@"this error should never happen credentials are not set, can't really ever happen, something is really wrong here");
    }
    
}

- (void) cleanupCurrentUploadView {
    self.currentUploadOperation = nil;
    
    self.currentlyUploadingImage.hidden = TRUE;
    self.currentlyUploadingImage.image = nil;
    //    self.imagesToUpload.hidden = TRUE;
    [self imagesToUpload].text = [NSString stringWithFormat:@"%d", APP_DELEGATE.networkQueue.operationCount];
    self.uploadProgressBar.progress = 0.0;
    self.cancelUpload.hidden = TRUE;
}

@end
