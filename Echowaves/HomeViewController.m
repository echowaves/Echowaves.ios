//
//  HomeViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "HomeViewController.h"
#import "EWWave.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (IBAction)backToHomeViewController:(UIStoryboardSegue *)segue
{
    NSLog(@"from segue id: %@", segue.identifier);
    [EWWave tuneOut];
}



@end
