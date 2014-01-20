//
//  SignUpViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController

- (void) signInWith:(NSString*)waveName andPassowrd:(NSString*)password;
- (void) create:(NSString*)waveName withPassowrd:(NSString*)password;

@property (nonatomic, strong) UITextField *waveName;
@property (nonatomic, strong) UITextField *wavePassword;

@end
