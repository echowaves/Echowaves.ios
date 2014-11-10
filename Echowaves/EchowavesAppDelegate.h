//
//  EchowavesAppDelegate.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

@import UIKit;

#import "WavingViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EchowavesAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//currently selected wave name
@property (strong, nonatomic) NSString *currentWaveName;
//currently selected wave index in the waves picker
@property (nonatomic)             long  currentWaveIndex;

@property (weak, nonatomic) WavingViewController *wavingViewController;

@property (atomic, strong) NSOperationQueue *networkQueue;
//@property (atomic, strong) NSTimer *aTimer;

@property (strong, nonatomic) NSString *deviceToken;

@property (strong, nonatomic) NSString *shareActionToken;

- (void)checkForInitialViewToPresent;

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