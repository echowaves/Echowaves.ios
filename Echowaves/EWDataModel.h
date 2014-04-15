//
//  EWDataModel.h
//  Echowaves
//
//  Created by Dmitry on 1/22/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWDataModel : NSObject

+ (void)showLoadingIndicator:(id)sender;
+ (void)hideLoadingIndicator:(id)sender;
+ (BOOL)isLoadingIndicatorShowing;
+ (void)showAlertWithMessage:(NSString *)message FromSender:(id)sender;
+ (void)showAlertWithMessageAndCancelButton:(NSString *)message
                                 FromSender:(id)sender;
+ (void)showErrorAlertWithMessage:(NSString *)message FromSender:(id)sender;

@end
