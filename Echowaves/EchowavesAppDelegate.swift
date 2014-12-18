//
//  AppDelegate.swift
//  EWSwift
//
//  Created by D on 11/1/14.
//  Copyright (c) 2014 D. All rights reserved.
//

import UIKit

let EWHost = "http://echowaves.com"
let APP_DELEGATE = UIApplication.sharedApplication().delegate as EchowavesAppDelegate
let EWAWSBucket = "http://images.echowaves.com"
let USER_DEFAULTS = NSUserDefaults.standardUserDefaults()


@UIApplicationMain class EchowavesAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //currently selected wave name
    var currentWaveName = ""
    //currently selected wave index in the waves picker
    var currentWaveIndex = 0
    
    var wavingViewController:WavingViewController!
    var navController:UINavigationController!
    
    let networkQueue = NSOperationQueue()
    
    var deviceToken = ""
    
    var shareActionToken = ""
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // setup Flurry
        Flurry.startSession("77TXPC3GDBGYX4NM8WNN")         // replace flurryKey with your own key
        Flurry.setCrashReportingEnabled(true)  // records app crashing in Flurry
        Flurry.logEvent("Start Application")   // Example of even logging
        Flurry.setSessionReportsOnCloseEnabled(false)
        Flurry.setSessionReportsOnPauseEnabled(false)
        Flurry.setBackgroundSessionEnabled(true)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound|UIUserNotificationType.Alert|UIUserNotificationType.Badge, categories: nil))
        
        // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
        AFNetworkReachabilityManager.sharedManager().startMonitoring();
        
        networkQueue.name = "com.echowaves.app.networkqueue";
        
        networkQueue.maxConcurrentOperationCount = 1;
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status.hashValue {
            case AFNetworkReachabilityStatus.ReachableViaWWAN.hashValue, AFNetworkReachabilityStatus.ReachableViaWiFi.hashValue:
                self.networkQueue.suspended = false
            case AFNetworkReachabilityStatus.NotReachable.hashValue, AFNetworkReachabilityStatus.Unknown.hashValue:
                self.networkQueue.suspended = true
            default:
                self.networkQueue.suspended = true
            }
        }
        
        
        
        //Set bar appearance
        UINavigationBar.appearance().barTintColor = UIColor(rgb: 0xFFA500)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        if let credential:NSURLCredential = EWWave.getStoredCredential() {
            currentWaveName = credential.user!
        } else {
            currentWaveName = ""
        }
        
        currentWaveIndex = 0
        
        //initalize wavingViewController
        //        self.wavingViewController = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("WavingViewController") as WavingViewController
        
        
        return true
    }
    
    
    func getPhotosCountSinceLast(completionHandler:(count:Int) ->Void) -> NSDate {
        
        
        var currentDateTime:NSDate? = USER_DEFAULTS.objectForKey("lastCheckTime") as? NSDate
        
        if currentDateTime == nil {
            currentDateTime = NSDate()
            USER_DEFAULTS.setObject(currentDateTime, forKey: "lastCheckTime")
        }
        
        EWImage.checkForNewAssetsToPostToWaveSinceDate(currentDateTime!,
            success: { (assets) -> () in
                completionHandler(count: assets.count)
            },
            failure: { (error) -> () in
                completionHandler(count: 0)
        })
        return currentDateTime!
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func checkForInitialViewToPresent() -> Void {
        if self.shareActionToken != "" && self.navController != nil {
            self.presentDetailedImageBasedOnShareToken()
        }
    }
    
    
    func presentDetailedImageBasedOnShareToken() -> Void {
        EWImage.retreiveImageByToken(
            APP_DELEGATE.shareActionToken,
            success: { (imageName, fromWaveName) -> () in
                
                let pickAWaveViewController = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("PickAWaveView") as AcceptBlendingRequestViewController
                
                pickAWaveViewController.origToWave = self.currentWaveName
                pickAWaveViewController.toWave = self.currentWaveName
                pickAWaveViewController.fromWave = fromWaveName

                
                self.navController.pushViewController(pickAWaveViewController, animated: true)
                
                
                let detailedImageViewController:DetailedImageViewController = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("DetailedImageView") as DetailedImageViewController
                
                detailedImageViewController.imageName = imageName
                detailedImageViewController.waveName = fromWaveName
                detailedImageViewController.imageIndex = 0
                
                let backButton:UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
                
                detailedImageViewController.title = "Preview"

                pickAWaveViewController.navigationItem.backBarButtonItem = backButton

                self.navController.pushViewController(detailedImageViewController, animated: true)
//                pickAWaveViewController.presentViewController(detailedImageViewController, animated: true, completion: nil)
                
                
                APP_DELEGATE.shareActionToken = "";//release the token
                
            },
            failure: { (error) -> () in
                if APP_DELEGATE.currentWaveName  != "" {
                    EWImage.showAlertWithMessage("Token expired...", fromSender: self)
                }
                NSLog("error retreiving token")
        })
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSLog("++++++++++++++++++called applicationDidBecomeActive")
        self.wavingViewController?.updatePhotosCount()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        self.checkForInitialViewToPresent()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
        NSLog("My token is^^^^^^^^^^^^^^^^^^^^^^^^^: \(self.deviceToken)")
        
        let credential:NSURLCredential = EWWave.getStoredCredential()!
        
        if credential.user != "" {
            EWWave.storeIosToken(credential.user!,
                token: self.deviceToken,
                success: { (waveName) -> () in
                    NSLog("stored device token for: \(waveName)")
                },
                failure: { (errorMessage) -> () in
                    NSLog("failed storing deviceToken \(errorMessage)")
            })
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Failed to get token, error^^^^^^^^^^^^^^^^^^^^^^^: \(error)")
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        NSLog("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< url: \(url.description)")
        
        //lets parse query string params and extract token
        let params = NSMutableDictionary()
        for param in url.query!.componentsSeparatedByString("&") {
            let elts = param.componentsSeparatedByString("=")
            if elts.count < 2 {
                continue
            }
            params.setObject(elts[1], forKey: elts[0])
        }
        
        self.shareActionToken = params.valueForKey("token") as String
        
        return true
    }
    
    
    
}

//http://all-free-download.com/free-vector/vector-web-design/under_construction_template_241387_download.html
//https://www.iconfinder.com/free_icons
//https://www.iconfinder.com/search/?q=iconset%3Awpzoom-developer-icon-set

//http://www.absoluteripple.com/1/post/2013/08/using-ios-storyboard-segues.html


//http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1

// creating JKS store
// https://github.com/timewarrior/herolabs-apns
// http://www.agentbob.info/agentbob/79-AB.html

// nsoperation queue
// http://www.raywenderlich.com/19788/how-to-use-nsoperations-and-nsoperationqueues