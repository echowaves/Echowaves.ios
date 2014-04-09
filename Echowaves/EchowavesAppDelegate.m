//
//  EchowavesAppDelegate.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesAppDelegate.h"
#import "HomeViewController.h"
#import "Flurry.h"

@implementation EchowavesAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Flurry setCrashReportingEnabled:YES];
    [Flurry setSessionReportsOnCloseEnabled:NO];
    [Flurry setSessionReportsOnPauseEnabled:NO];
    [Flurry setBackgroundSessionEnabled:YES];

    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry startSession:@"77TXPC3GDBGYX4NM8WNN"];

    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    
    self.networkQueue = [[NSOperationQueue alloc] init];
    self.networkQueue.name = @"com.echowaves.app.networkqueue";

    [self.networkQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    
    // if you want it to be a serial queue, set maxConcurrentOperationCount to 1
    //
    self.networkQueue.maxConcurrentOperationCount = 1;
    
    //
    // if you want it to be a concurrent queue, set it to some reasonable value
    //
    // self.networkQueue.maxConcurrentOperationCount = 4;
    

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self.networkQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
            default:
                [self.networkQueue setSuspended:YES];
                break;
        }
    }];
    
    //Set bar appearance
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xFFA500)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, nil]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == self.networkQueue && [keyPath isEqualToString:@"operations"]) {
        if ([self.networkQueue.operations count] == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");
            
            NSLog(@"!!!!!!!!!!!!!!!images to post operations: %lu", (unsigned long)[self.networkQueue.operations count]);
            
                [EWWave sendPushNotifyForWave:APP_DELEGATE.currentWaveName
                                        badge:1
                                      success:^{
                                          NSLog(@"!!!!!!!!!!!!!!!pushed notify successfully");
                                      }
                                      failure:^(NSError *error) {
                                          NSLog(@"this error should never happen %@", error.description);
                                      }];
            
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
    
}

//-(void)timerFired:(NSTimer *) theTimer
//{
//    if(self.networkQueue.operationCount == 0) {
//        [self.wavingViewController.imagesToUpload setText:@"0"];
//    } else {
//        [self.wavingViewController.imagesToUpload setText:[NSString stringWithFormat:@"%d", self.networkQueue.operationCount]];
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [self.aTimer invalidate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self checkForUpload];
}


- (void)checkForUpload {
    if(self.wavingViewController.waving.on) {
    UploadProgressViewController *uploadProgressViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"UploadView"];
    [(UINavigationController *)self.window.rootViewController pushViewController:uploadProgressViewController animated:YES];
    }
    // [pvc release]; if not using ARC
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"++++++++++++++++++called applicationDidBecomeActive");
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    
//    self.aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                   target:self
//                                                 selector:@selector(timerFired:)
//                                                 userInfo:nil
//                                                  repeats:YES];
//    [self.aTimer fire];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.


    
//    if (self.wavingViewController.waving.on) {
//        //this prevents from loosing session in case the server was bounced
////        [echowavesViewController tuneIn];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.uploadProgressViewController checkForNewImages];
//        });
//    }
    
    
//    [self checkForUpload];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    self.deviceToken = [[[deviceToken description]
                         stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                        stringByReplacingOccurrencesOfString:@" "
                        withString:@""];
	NSLog(@"My token is^^^^^^^^^^^^^^^^^^^^^^^^^: %@", [self deviceToken]);
    
    NSURLCredential *credential = [EWWave getStoredCredential];
    if([credential.user length]) {
        [EWWave storeIosTokenForWave:credential.user
                           token:self.deviceToken
                         success:^(NSString *waveName) {
                             NSLog(@"stored device token for: %@", waveName);
                         }
                         failure:^(NSString *errorMessage) {
                             NSLog(@"failed storing deviceToken %@", errorMessage);
                         }];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error^^^^^^^^^^^^^^^^^^^^^^^: %@", error);
}
@end
