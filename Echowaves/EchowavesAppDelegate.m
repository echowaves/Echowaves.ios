//
//  EchowavesAppDelegate.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesAppDelegate.h"
#import "HomeViewController.h"
#import "DetailedImageViewController.h"
#import "PickAWaveViewController.h"
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

//    [self.networkQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@",,,,,,,,,,,,,,,,,applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.uploadProgressViewController comeBack];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@",,,,,,,,,,,,,,,,,applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [self.aTimer invalidate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>> applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}


- (void)checkForInitialViewToPresent {
    if([APP_DELEGATE shareActionToken]) {
        [self presentDetailedImageBasedOnShareToken];
    } else {
        [self presentUploadView];
    }
}

- (void) presentUploadView {
    if(self.wavingViewController.waving.on) {
        self.uploadProgressViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"UploadView"];
        [(UINavigationController *)self.window.rootViewController pushViewController:self.uploadProgressViewController animated:YES];
        
    }
    
}

- (void) presentDetailedImageBasedOnShareToken {
        [EWImage retreiveImageByToken:[APP_DELEGATE shareActionToken]
                              success:^(NSString *imageName, NSString *waveName) {

                                  
                                  PickAWaveViewController *pickAWaveViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"PickAWaveView"];
                                  [(UINavigationController *)self.window.rootViewController pushViewController:pickAWaveViewController animated:NO];

                                  DetailedImageViewController *detailedImageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImageView"];
                                  
                                  detailedImageViewController.imageName = imageName;
                                  detailedImageViewController.waveName = waveName;
                                  
                                  
                                  [pickAWaveViewController.navigationController pushViewController:detailedImageViewController animated:NO];

                                  


                                  
                                  
                                  APP_DELEGATE.shareActionToken = nil;//release the token
                                  
                              } failure:^(NSError *error) {
                                  [EWImage showAlertWithMessage:@"Token expired..." FromSender:nil];
                                  NSLog(@"error retreiving token");
                              }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"++++++++++++++++++called applicationDidBecomeActive");
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self checkForInitialViewToPresent];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< url: %@", url.description);

    //lets parse query string params and extract token
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *param in [[url query]componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    
    self.shareActionToken = [params valueForKey:@"token"];

    return YES;
}

@end
