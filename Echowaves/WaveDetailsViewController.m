//
//  WaveDetailsViewController.m
//  Echowaves
//
//  Created by Dmitry on 4/8/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "WaveDetailsViewController.h"

@interface WaveDetailsViewController ()

@end

@implementation WaveDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self waveName].text = [APP_DELEGATE waveName];

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
                       [EWWave showErrorAlertWithMessage:errorMessage FromSender:nil];
                   }];
    
}

- (IBAction)deleteWave:(id)sender {
    [EWWave showAlertWithMessageAndCancelButton:@"Will remove wave and all it's photos. Sure?" FromSender:self];

}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
//        [EWWave deleteChildWave];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

@end
