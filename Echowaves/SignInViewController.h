//
//  SignInViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *waveName;
@property (strong, nonatomic) IBOutlet UITextField *wavePassword;
@property (strong, nonatomic) IBOutlet UIButton *tuneInButton;

@end
