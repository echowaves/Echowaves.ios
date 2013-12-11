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
@property (weak, nonatomic) IBOutlet UILabel *appStatus;
@property (nonatomic, retain, readwrite) IBOutlet UIImageView *imageCurrentlyUploading;


@property (strong, atomic) AFHTTPRequestOperationManager *manager;

@property (nonatomic, assign, getter=isWaving) BOOL waving;

@property (strong, atomic) NSDate *lastCheckTime;
@property (strong, atomic) NSMapTable *imagesToPost;


- (BOOL) checkForImages;
- (BOOL) postNewImages;

@end
