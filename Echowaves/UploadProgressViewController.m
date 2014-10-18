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

@implementation UploadProgressViewController


-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self cleanupCurrentUploadView];
    NSLog(@"#### WavingViewController viewDidLoad ");
    [self currentlyUploadingImage].contentMode = UIViewContentModeScaleAspectFit;
    self.uploadProgressBar.progress = 0.0;

    
//    UIBarButtonItem *btnPause = [[UIBarButtonItem alloc]
//                                initWithBarButtonSystemItem:UIBarButtonSystemItemPause
//                                target:self
//                                action:@selector(OnClick_btnPause:)];
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.rightBarButtonItem = btnPause;
    self.navigationItem.titleView = [UIView new];//we want to disable title -- too much info on the screen
}

-(IBAction)OnClick_btnPause:(id)sender  {
    [self cancelingCurrentUploadOperation:self];
    self.deactivated = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.title = @"streaming wave";
    //    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForNewAssets:-1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkForNewAssets:(long) assetsCount {
    //try to sign in to see if connection is awailable
    NSURLCredential *credential = [EWWave getStoredCredential];
    if(credential && !self.deactivated) {
        NSLog(@"User %@ already connected with password.", credential.user);
        
        [EWWave tuneInWithName:credential.user
                   andPassword:credential.password
                       success:^(NSString *waveName) {
                           NSLog(@"successsfully signed in");
                           
                           [EWImage checkForNewAssetsToPostToWaveSinceDate:(NSDate*)[USER_DEFAULTS objectForKey:@"lastCheckTime"]
                                success:^(NSArray* assets){
                                                         
//                                                         [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)assets.count];
                                                         //the following like is needed to force update the label
//                                                         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];

                                                         
                                                         NSLog(@"************* images to post %lu", (unsigned long)assets.count);
                                                         if(assets.count == 0) { // this means nothing is found to be posted
                                                             [self comeBack];
                                                             
                                                             if (assetsCount > 0) {
                                                                 [EWWave sendPushNotifyBadge:assetsCount
                                                                                       success:^{
                                                                                           NSLog(@"!!!!!!!!!!!!!!!pushed notify successfully %ld", assetsCount);
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                           NSLog(@"this error should never happen %@", error.description);
                                                                                       }];
                                                             }
                                                         } else {
//                                                             for(ALAsset *asset in assets) {
                                                             ALAsset* asset = assets[0];
                                                                 [EWImage operationFromAsset:asset
                                                                        forWaveName:waveName
                                                                       success:^(AFHTTPRequestOperation *operation, UIImage *image, NSDate *currentAssetDateTime) {
                                                                           __weak  AFHTTPRequestOperation* weakOperation = operation;
//                                                                           NSLog(@"1");
                                                                           [weakOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {                                                                          
                                                                               if(!self.currentlyUploadingImage.image) { // beginning new upload operation here
                                                                                   self.cancelUpload.hidden = FALSE;
                                                                                   self.uploadProgressBar.hidden = FALSE;
                                                                                   
                                                                                   self.currentUploadOperation = weakOperation;
                                                                                   self.currentlyUploadingImage.image = image;
                                                                                   self.currentlyUploadingImage.hidden = FALSE;
                                                                                   [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)assets.count];
                                                                                   //                                            [self imagesToUpload].hidden = FALSE;
                                                                               }
                                                                               
                                                                               self.uploadProgressBar.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
                                                                           }];
                                                                           [weakOperation setCompletionBlock:^{
                                                                               [self cleanupCurrentUploadView];
                                                                               if( self.deactivated == NO) {
                                                                                   [USER_DEFAULTS setObject:currentAssetDateTime forKey:@"lastCheckTime"];
                                                                                   [USER_DEFAULTS synchronize];
                                                                                   if(assetsCount > 0) {
                                                                                       [self checkForNewAssets:assetsCount];
                                                                                   } else {
                                                                                       [self checkForNewAssets:assets.count];
                                                                                   };
                                                                               }
                                                                           }];
                                                                           [APP_DELEGATE.networkQueue addOperation:weakOperation];
//                                                                           [APP_DELEGATE.networkQueue setSuspended:NO];
                                                                       } //success
                                                                  ];// operationFromAsset
//                                                             } // for assets
                                                         } //else
                                                     } // when checking done
                                                            whenError:^(NSError *error) {
                                                                NSLog(@"this error should never happen %@", error.description);
                                                                [EWWave showErrorAlertWithMessage:[error description] FromSender:nil];
                                                                [self comeBack];

                                                            }];
                                
                       } // tune in with name
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:nil];
                           [self comeBack];
                       }];// tune in with name
        
        
        NSLog(@"++++++++++++++++++++++++++++++++++++++++++++++++++ done posting, assetsCount %ld", assetsCount);
    } else { // credentials are not set, can't really ever happen, something is really wrong here
        NSLog(@"this error should never happen credentials are not set, can't really ever happen, something is really wrong here 1");
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
//    [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)APP_DELEGATE.networkQueue.operationCount];
    self.uploadProgressBar.progress = 0.0;
    self.uploadProgressBar.hidden = TRUE;
    self.cancelUpload.hidden = TRUE;
}

- (void) comeBack {
    NSLog(@"........comeBack");
//    APP_DELEGATE.uploadProgressViewController = nil;

    //    [self.navigationController popViewControllerAnimated:YES];
    // here need to pop 2 levels out
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];

    self.deactivated = YES;
//    [(UINavigationController *)APP_DELEGATE.window.rootViewController popViewControllerAnimated:YES];
}

//- (void)dealloc {
//    NSLog(@"...................dealllocating uploadprogressviewcontroller");
//}

@end
