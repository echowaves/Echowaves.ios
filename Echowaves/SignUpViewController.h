//
//  SignUpViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *waveName;
@property (strong, nonatomic) IBOutlet UITextField *wavePassword;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassword;

@end
