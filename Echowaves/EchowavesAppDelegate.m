//
//  EchowavesAppDelegate.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesAppDelegate.h"
#import "EchowavesViewController.h"

@implementation EchowavesAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"called didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
//    [application setMinimumBackgroundFetchInterval:1];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"called applicationWillResignActive");

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"called applicationDidEnterBackground");
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"called applicationWillEnterForeground");

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"called applicationDidBecomeActive");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    
    [echowavesViewController postLastImages];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"called applicationWillTerminate");

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    http://www.objc.io/issue-5/multitasking.html
    NSLog(@"called performFetchWithCompletionHandler");
    NSLog(@"I'm running in the background!");
    // Execute your background request here:
    
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    
    BOOL imageFound = [echowavesViewController postLastImages];
    
    //Make sure to run one of the following methods:
    if(imageFound == YES) {
        NSLog(@"returning UIBackgroundFetchResultNewData");
        completionHandler(UIBackgroundFetchResultNewData);
    } else if (imageFound == NO) {
        NSLog(@"returning UIBackgroundFetchResultNoData");
        completionHandler(UIBackgroundFetchResultNoData);
    }
//    NSLog(@"returning UIBackgroundFetchResultFailed");
//    completionHandler(UIBackgroundFetchResultFailed);
}

/** when a push notification comes it, perform a background fetch/push */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"called didReceiveRemoteNotification");
    /*
     * Inspect the userInfo dictionary for any data values passed from the server.
     * Ideal would be a string and ID for a remote data object to be fetched here.
     */
}

@end
