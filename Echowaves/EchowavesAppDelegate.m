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
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
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
//    http://developer.blueearth.net/2011/12/02/quick-tip-clearing-up-ios-multitasking/
    NSLog(@"called applicationDidEnterBackground");
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Create and register your timers
        
        // ...
        
        NSTimer *timer = [ NSTimer
                 scheduledTimerWithTimeInterval:30
                 
                 target:self
                 
                 selector:@selector(backgroundUpdate)
                 
                 userInfo:nil
                 
                 repeats:NO
                 ];
        
        //change to NSRunLoopCommonModes
        
        [ [NSRunLoop currentRunLoop]
         addTimer:timer
         forMode:NSRunLoopCommonModes
         ];
        
        // Create/get a run loop an run it
        
        // Note: will return after the last timer's delegate has completed its job
        
        [[NSRunLoop currentRunLoop] run];
        
    });
    
    __block UIBackgroundTaskIdentifier back =
    [[UIApplication sharedApplication]
     beginBackgroundTaskWithExpirationHandler:^{
         
         [self startCoreUpdate];
         
         [ [UIApplication sharedApplication]
          endBackgroundTask:back
          ];
         
     } ];
    
//    - See more at: http://developer.blueearth.net/2011/12/02/quick-tip-clearing-up-ios-multitasking/#sthash.usmXPGVI.dpuf
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



//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
////    http://www.objc.io/issue-5/multitasking.html
//    NSLog(@"called performFetchWithCompletionHandler");
//    // Execute your background request here:
//    completionHandler(UIBackgroundFetchResultNoData);
//}


/** when a push notification comes it, perform a background fetch/push */
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
//{
//    NSLog(@"called didReceiveRemoteNotification");
//    /*
//     * Inspect the userInfo dictionary for any data values passed from the server.
//     * Ideal would be a string and ID for a remote data object to be fetched here.
//     */
//}




- (void) startCoreUpdate {
    NSLog(@"called postLastImages");
    NSLog(@"I'm running in the background!");
    // Execute your background request here:
    
    EchowavesViewController* echowavesViewController = (EchowavesViewController*)  self.window.rootViewController;
    
    BOOL imageFound = [echowavesViewController postLastImages];
    
    //Make sure to run one of the following methods:
    if(imageFound == YES) {
        NSLog(@"image fond -- posted");
    } else if (imageFound == NO) {
        NSLog(@"image not found -- skipped");
    }

}

-(void)backgroundUpdate

{
    
    [ self startCoreUpdate ];
    
    __block UIBackgroundTaskIdentifier back =
    [[UIApplication sharedApplication]
     beginBackgroundTaskWithExpirationHandler:^{
         
         [self startCoreUpdate];
         
         [ [UIApplication sharedApplication]
          endBackgroundTask:back
          ];
         
     } ];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    // Check first to see if notification was fired while app was active.
    
    if (state != UIApplicationStateActive) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Create and register your timers
            
            // ...
            
            NSTimer *timer = [ NSTimer
                     scheduledTimerWithTimeInterval:30
                     
                     target:self
                     
                     selector:@selector(backgroundUpdate)
                     
                     userInfo:nil
                     
                     repeats:NO
                     ];
            
            //change to NSRunLoopCommonModes
            
            [ [NSRunLoop currentRunLoop]
             addTimer:timer
             forMode:NSRunLoopCommonModes
             ];
            
            // Create/get a run loop an run it
            
            // Note: will return after the last timer's delegate has completed its job
            
            [[NSRunLoop currentRunLoop] run];
            
        });
        
    }
    
}


@end
