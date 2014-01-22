//
//  HomeViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/21/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

// http://www.absoluteripple.com/1/post/2013/08/using-ios-storyboard-segues.html
- (IBAction)backToHomeViewController:(UIStoryboardSegue *)segue
{
    NSLog(@"from segue id: %@", segue.identifier);
}


@end
