//
//  EchowavesViewController.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@interface EchowavesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *waveName;
@property (weak, nonatomic) IBOutlet UITextField *wavePassword;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *appStatus;
@property (weak, nonatomic) IBOutlet UILabel *pictruresCount;


@property (strong, nonatomic) IBOutlet UIImageView *imageCurrentlyUploading;

@property (atomic, assign, getter=isWaving) BOOL waving;

@property (strong, atomic) NSDate *lastCheckTime;

@property (nonatomic, strong) NSOperationQueue *networkQueue;

@property (nonatomic, strong) NSTimer *aTimer;

- (BOOL) checkForNewImages;
- (BOOL) postNewImages:NSMutableArray;
@end
