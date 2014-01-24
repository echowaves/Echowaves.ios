//
//  EWDataModel.m
//  Echowaves
//
//  Created by Dmitry on 1/22/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EWDataModel.h"

@implementation EWDataModel

static UIAlertView *loadingIndicator;

+ (void)showLoadingIndicator:(id)sender {
    //UIAlertView *loadingIndicator;
    if (!loadingIndicator) loadingIndicator = [[UIAlertView alloc] initWithTitle:@"Loading..." message:@"Please Wait" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    
//    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
//        if(!progress) progress = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)];
//        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        
//        [loadingIndicator addSubview:progress];
//        [progress startAnimating];
//    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingIndicator show];
}

+ (void)hideLoadingIndicator:(id)sender {
    [loadingIndicator dismissWithClickedButtonIndex:0 animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (BOOL)isLoadingIndicatorShowing {
    return [loadingIndicator isVisible];
}

+ (void)showErrorAlertWithMessage:(NSString *)message FromSender:(id)sender{
    UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:sender cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    errorMessage.tag = 10001;
    
    [errorMessage show];
}


@end
