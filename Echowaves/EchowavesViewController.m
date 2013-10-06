//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesViewController.h"

@interface EchowavesViewController ()

@end

@implementation EchowavesViewController



- (IBAction)startWaving:(UIButton *)sender {
    NSLog(@" wave name %@ , wave password %@", _waveName.text, _wavePassword.text);
    [_waveName setEnabled:NO];
    [_wavePassword setEnabled:NO];
    [sender setEnabled:NO];
    [sender setTitle:@"Currently Waving" forState:UIControlStateNormal];
    NSLog(@"button should be disabled now");

}

@end
