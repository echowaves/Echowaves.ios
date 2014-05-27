//
//  DetailedImageViewController.h
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface DetailedImageViewController : UIViewController <UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) NSString *waveName;
@property (strong, nonatomic) NSString *imageName;

@property (weak, nonatomic) IBOutlet UIImageView *currImageView;

@property (strong, nonatomic) IBOutlet UILabel *waveNameLable;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end
