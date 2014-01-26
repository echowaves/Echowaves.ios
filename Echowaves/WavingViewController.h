//
//  EchowavesViewController.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@interface WavingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *imagesToUpload;

@property (strong, nonatomic) IBOutlet UISwitch *waving;

@property (strong, atomic) NSDate *lastCheckTime;

@property (atomic, strong) NSOperationQueue *networkQueue;

@property (atomic, strong) NSTimer *aTimer;



@end
//nsuserdefaults
//http://stackoverflow.com/questions/8565087/afnetworking-and-cookies/17997943#17997943