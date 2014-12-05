//
//  WaveDetailsViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/8/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "Echowaves-Swift.h"
#import "WaveDetailsViewController.h"

@interface WaveDetailsViewController ()

@end

@implementation WaveDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self waveName].text = [APP_DELEGATE currentWaveName];
    
    [EWWave getWaveDetails:[self waveName].text
                   success:^(NSDictionary *waveDetails) {
                       //show delete button only for child waves
                       if([waveDetails objectForKey:@"parent_wave_id"] != [NSNull null]) {
                           [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                       
                                                                                                                    target:self
                                                                                                                    action:@selector(deleteWave:)];
                       } else {
                           [self deleteWaveButton].hidden=YES;
                       }
                   } failure:^(NSString *errorMessage) {
                       [EWWave showErrorAlertWithMessage:errorMessage fromSender:nil];
                   }];
    
}

- (IBAction)deleteWave:(id)sender {
    [EWWave showAlertWithMessageAndCancelButton:@"Will remove wave and all it's photos. Sure?"
                                       okAction:^(UIAlertAction *okAction) {
                                           [EWWave deleteChildWave:[self.waveName text]
                                                           success:^(NSString *waveName) {
                                                               APP_DELEGATE.currentWaveName = @"";// this will be an indicator for the wavingViewController to reload and reinitialize the proper waveName
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }
                                                           failure:^(NSString *errorMessage) {
                                                               [EWWave showErrorAlertWithMessage:errorMessage fromSender:nil];
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }];
                                       }
                                     fromSender:self];
}



@end
