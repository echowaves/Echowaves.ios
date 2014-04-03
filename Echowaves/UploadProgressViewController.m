//
//  UploadProgressViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "UploadProgressViewController.h"
#import "EWWave.h"
#import "EWImage.h"

@interface UploadProgressViewController ()

@end

@implementation UploadProgressViewController


-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Posting Pictures";
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view.
    self.delegate = self;
    [self cleanupCurrentUploadView];
    NSLog(@"#### WavingViewController viewDidLoad ");
    [self currentlyUploadingImage].contentMode = UIViewContentModeScaleAspectFit;
    self.uploadProgressBar.progress = 0.0;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkForNewImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                           
                           if (APP_DELEGATE.wavingViewController.waving.on) {
                               [EWImage checkForNewImagesToPostToWave:waveName
                                                       whenImageFound:^(UIImage *image, NSDate *imageDate) {
                                                           
                                                           AFHTTPRequestOperation* _operation = [EWImage createPostOperationFromImage:image
                                                                                                                            imageDate:imageDate
                                                                                                                          forWaveName:waveName];
                                                           __weak AFHTTPRequestOperation *operation = _operation;
                                                           
                                                           [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                                                               NSInteger totalBytesWritten,
                                                                                               NSInteger totalBytesExpectedToWrite) {
                                                               if(!self.currentlyUploadingImage.image) { // beginning new upload operation here
                                                                   self.cancelUpload.hidden = FALSE;
                                                                   self.uploadProgressBar.hidden = FALSE;

                                                                   self.currentUploadOperation = operation;
                                                                   self.currentlyUploadingImage.image = image;
                                                                   self.currentlyUploadingImage.hidden = FALSE;
                                                                   [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)APP_DELEGATE.networkQueue.operationCount];
                                                                   //                                            [self imagesToUpload].hidden = FALSE;
                                                               }
                                                               
                                                               self.uploadProgressBar.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
                                                               //                                        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
                                                               //                                        NSLog(@"progress %@", [[NSNumber numberWithDouble:((float)totalBytesWritten/totalBytesExpectedToWrite)] stringValue]);
                                                               
                                                           }];
                                                           [operation setCompletionBlock:^{
                                                               [self cleanupCurrentUploadView];
                                                               if(APP_DELEGATE.networkQueue.operationCount == 0) { // this is the last operation in the queue -- time to come back
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                               }
                                                           }];
                                                           
                                                           NSLog(@"@@@@@@@@@@@@@ image found %@", imageDate.description);
                                                           
                                                           [imagesToPostOperations addObject:operation];
                                                           
                                                           [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)imagesToPostOperations.count];
                                                           //the following like is needed to force update the label
                                                           [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
                                                           
                                                           
                                                           NSLog(@"@@@@@@@@@@@@@@@@ images to post %lu", (unsigned long)imagesToPostOperations.count);
                                                           
                                                       }
                                                     whenCheckingDone:^{
                                                         
                                                         //                                  [self appStatus].text = @"uploading now";
                                                         //                                  [self imagesToUpload].hidden = TRUE;
                                                         
                                                         NSLog(@"************* images to post %lu", (unsigned long)imagesToPostOperations.count);
                                                         if(imagesToPostOperations.count == 0) { // this means nothing is found to be posted
                                                             [NSThread sleepForTimeInterval:2.0f];
                                                             [self.navigationController popViewControllerAnimated:YES];
                                                         } else {
                                                             [EWImage postAllNewImages:imagesToPostOperations];
                                                         }
//                                                         [EWImage postAllNewImages:imagesToPostOperations];
                                                         
                                                     }
                                                            whenError:^(NSError *error) {
                                                                NSLog(@"this error should never happen %@", error.description);
                                                                [EWWave showErrorAlertWithMessage:[error description] FromSender:self];
                                                                [self.navigationController popViewControllerAnimated:YES];
                                                            }];
                               
                           }
                           
                       }
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:self];
                           [self.navigationController popViewControllerAnimated:YES];
                       }];
        
        
        
    } else { // credentials are not set, can't really ever happen, something is really wrong here
        NSLog(@"this error should never happen credentials are not set, can't really ever happen, something is really wrong here");
    }
    
}

- (IBAction)cancelingCurrentUploadOperation:(id)sender {
    [self.currentUploadOperation cancel];
    [self cleanupCurrentUploadView];
}


- (void) cleanupCurrentUploadView {
    self.currentUploadOperation = nil;
    
    self.currentlyUploadingImage.hidden = TRUE;
    self.currentlyUploadingImage.image = nil;
    //    self.imagesToUpload.hidden = TRUE;
    [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)APP_DELEGATE.networkQueue.operationCount];
    self.uploadProgressBar.progress = 0.0;
    self.uploadProgressBar.hidden = TRUE;
    self.cancelUpload.hidden = TRUE;
}

-(void) pictureSaved
{
    [self checkForNewImages];
}


@end
