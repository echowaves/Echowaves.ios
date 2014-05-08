//
//  DetailedImageViewController.h
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface DetailedImageViewController : UIViewController <UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) NSDictionary *imageFromJson;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UILabel *waveName;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
