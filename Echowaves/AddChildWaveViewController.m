//
//  AddChildWaveViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "AddChildWaveViewController.h"

@interface AddChildWaveViewController ()

@end

@implementation AddChildWaveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createChildWave].layer.cornerRadius = 4.0f;
    [self createChildWave].layer.borderWidth = 1.0f;
    [self createChildWave].layer.borderColor = UIColorFromRGB(0xFFA500).CGColor;
    
    [self childWaveName].layer.cornerRadius = 4.0f;
    [self childWaveName].layer.borderWidth = 1.0f;
    [self childWaveName].layer.borderColor = UIColorFromRGB(0xFFA500).CGColor;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.childWaveName becomeFirstResponder];
    self.childWaveName.text = [NSString stringWithFormat:@"%@.", APP_DELEGATE.currentWaveName];
}

- (IBAction)createChildWave:(id)sender {
    [EWWave createChildWaveWithName:[self childWaveName].text
                            success:^(NSString *waveName) {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            failure:^(NSString *errorMessage) {
                                [EWWave showErrorAlertWithMessage:errorMessage
                                                  FromSender:nil];
                                [self.navigationController popViewControllerAnimated:YES];

                            }];
}

@end
