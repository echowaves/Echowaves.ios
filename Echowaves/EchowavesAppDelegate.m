//
//  EchowavesAppDelegate.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//
#import "Flurry.h"

#import "EchowavesAppDelegate.h"
#import "EchowavesViewController.h"

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
    
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;

    echowavesViewController.networkQueue = [[NSOperationQueue alloc] init];
    echowavesViewController.networkQueue.name = @"com.echowaves.app.networkqueue";
    
    // if you want it to be a serial queue, set maxConcurrentOperationCount to 1
    //
    echowavesViewController.networkQueue.maxConcurrentOperationCount = 1;
    
    //
    // if you want it to be a concurrent queue, set it to some reasonable value
    //
    // self.networkQueue.maxConcurrentOperationCount = 4;
    
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [echowavesViewController.networkQueue setSuspended:NO];
                [echowavesViewController.appStatus setText:@"Network is not reachable, try again later."];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [echowavesViewController.networkQueue setSuspended:YES];
                [echowavesViewController.appStatus setText:@"Network is not reachable, try again later."];
                break;
        }
    }];
    return YES;
}

-(void)timerFired:(NSTimer *) theTimer
{
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    if(echowavesViewController.networkQueue.operationCount == 0) {
        [echowavesViewController.pictruresCount setText:[NSString stringWithFormat:@"Nothing to upload."]];
    } else {
        [echowavesViewController.pictruresCount setText:[NSString stringWithFormat:@"pending pictures %d...", echowavesViewController.networkQueue.operationCount]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    [echowavesViewController.aTimer invalidate];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    [echowavesViewController.aTimer fire];
    echowavesViewController.aTimer = nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"++++++++++++++++++called applicationDidBecomeActive");
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    echowavesViewController.aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                      target:self
                                                                    selector:@selector(timerFired:)
                                                                    userInfo:nil
                                                                     repeats:YES];
    [echowavesViewController.aTimer fire];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    if ([echowavesViewController isWaving]) {
        [echowavesViewController checkForNewImages];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
