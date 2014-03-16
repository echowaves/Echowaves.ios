//
//  EchowavesAppDelegate.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

@import UIKit;

#import "EWWave.h"
#import "WavingViewController.h"


@interface EchowavesAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *waveName;

@property (weak, nonatomic) WavingViewController *wavingViewController;

@property (atomic, strong) NSOperationQueue *networkQueue;
//@property (atomic, strong) NSTimer *aTimer;

@property (strong, nonatomic) NSString *deviceToken;

@end


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