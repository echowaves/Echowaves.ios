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

@interface DetailedImageViewController : UIViewController <UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate>
@property (atomic) NSUInteger imageIndex;
@property (atomic) bool fullSizeImageLoaded;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) NSString *waveName;
@property (strong, nonatomic) NSString *imageName;

@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *waveNameLable;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@property (strong, nonatomic) UINavigationItem *navItem;

@end
