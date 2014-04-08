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
static BOOL alertShowing;


+ (void)showLoadingIndicator:(id)sender {
    //UIAlertView *loadingIndicator;
    if (!loadingIndicator) loadingIndicator = [[UIAlertView alloc] initWithTitle:@"Loading..." message:@"Please Wait" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (!alertShowing) {
        [loadingIndicator show];
    }
    alertShowing = YES;
}

+ (void)hideLoadingIndicator:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [loadingIndicator dismissWithClickedButtonIndex:0 animated:YES];
    loadingIndicator = nil;
    alertShowing = NO;
}

+ (BOOL)isLoadingIndicatorShowing {
    return alertShowing;
}


+ (void)showAlertWithMessage:(NSString *)message FromSender:(id)sender {
    UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                           message:message
                                                          delegate:sender
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK", nil];
    alertMessage.tag = 10002;
    
    [alertMessage show];
    
};

+ (void)showAlertWithMessageAndCancelButton:(NSString *)message FromSender:(id)sender {
    UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                           message:message
                                                          delegate:sender
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
    alertMessage.tag = 10003;
    
    [alertMessage show];
    
};


+ (void)showErrorAlertWithMessage:(NSString *)message FromSender:(id)sender{
    UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:message
                                                          delegate:sender
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles: nil];
    errorMessage.tag = 10001;
    
    [errorMessage show];
}


@end
