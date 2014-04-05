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
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.childWaveName becomeFirstResponder];
    self.childWaveName.text = [NSString stringWithFormat:@"%@.", APP_DELEGATE.waveName];
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
