//
//  DetailedImageViewController.m
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "DetailedImageViewController.h"
#import "EWImage.h"

@interface DeleteImageAlertView : UIAlertView
@property (nonatomic) NSString *waveName;
@property (nonatomic) NSString *imageName;
@end
@implementation DeleteImageAlertView
@end


@implementation DetailedImageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //    NSLog(@"###########imageFromJson %@", self.imageFromJson);
    NSString* thumbImageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWAWSBucket, [self waveName], [self imageName]];
    NSString* imageUrl      = [NSString stringWithFormat:@"%@/img/%@/%@"      , EWAWSBucket, [self waveName], [self imageName]];
    
//    [self.navigationItem setPrompt:waveName];
    [[self waveNameLable] setText:[self waveName]];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat : @"yyyyMMddHHmmssSSSS"];
    NSString *dateString = [self.imageName substringWithRange:NSMakeRange(0, 18)];
    NSLog(@"imageName  = %@", self.imageName);
    NSLog(@"dateString = %@", dateString);
    NSDate *dateTime = [formatter dateFromString:dateString];
    
//    [formatter release];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [self setTitle:[formatter stringFromDate:dateTime]];
    
//    [[self navigationItem].backBarButtonItem setTitle:@" "];
    
    if ([self.waveName isEqualToString:[APP_DELEGATE currentWaveName]]) {
        
        UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(deleteImage)];

        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(shareImage)];
        
        self.navigationItem.rightBarButtonItems = @[shareButton, deleteButton];
    } else {
        [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                 target:self
                                                                                                 action:@selector(saveImage)];
        
    }
    self.progressView.progress = 0.0;
    [self.progressView setHidden:FALSE];

    [EWImage loadImageFromUrl:thumbImageUrl
                      success:^(UIImage *image) {
                          self.imageView.image = image;
                          self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                          
                          [EWImage loadImageFromUrl:imageUrl
                                            success:^(UIImage *image) {
                                                [self.progressView setHidden:TRUE];

                                                self.imageView.image = image;
                                                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                            }
                                            failure:^(NSError *error) {
                                                [EWDataModel showErrorAlertWithMessage:@"Error Loading image" FromSender:nil];
                                                NSLog(@"error: %@", error.description);
                                            }
                                           progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                               self.progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                                           }];

                      }
                      failure:^(NSError *error) {
                          [EWDataModel showErrorAlertWithMessage:@"Error Loading image" FromSender:nil];
                          NSLog(@"error: %@", error.description);
                      }
                     progress:nil];

    
    
    
}

//-(void) popBack {
//    [self.navigationController popViewControllerAnimated:YES];
//}


-(void)deleteImage {
    NSLog(@"deleting image");
    
    DeleteImageAlertView *alertMessage = [[DeleteImageAlertView alloc] initWithTitle:@"Alert"
                                                                             message:@"Delete?"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                                   otherButtonTitles:@"OK", nil];
    alertMessage.waveName = self.waveName;
    alertMessage.imageName = self.imageName;
    alertMessage.tag = 20002;
    [alertMessage show];

    
    
}

-(void)shareImage {
    NSLog(@"sharing image");
    
    ABPeoplePickerNavigationController *peoplePicker = [ABPeoplePickerNavigationController new];
    peoplePicker.peoplePickerDelegate = self;
//    peoplePicker.modalPresentationStyle = 
    [self presentViewController:peoplePicker animated:YES completion:^{
        NSLog(@"done presenting");
    }];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {//OK button clicked, let's delete the wave
        [EWImage showLoadingIndicator:self];
        [EWImage deleteImage:[(DeleteImageAlertView*)alertView imageName]
                      inWave:[(DeleteImageAlertView*)alertView waveName]
                     success:^{
                         [self.navigationController popViewControllerAnimated:YES];
                         [EWImage hideLoadingIndicator:self];
                     }
                     failure:^(NSError *error) {
                         [EWImage hideLoadingIndicator:self];
                         [EWImage showErrorAlertWithMessage:@"Unable to delete image" FromSender:nil];
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
        
    }
}


-(void)saveImage {
    [EWImage saveImageToAssetLibrary:[self.imageView image]
                             success:^{
                                 [EWDataModel showAlertWithMessage:@"Photo Saved to iPhone"
                                                        FromSender:nil];
                             }
                             failure:^(NSError *error) {
                                 [EWDataModel showErrorAlertWithMessage:@"Error saving" FromSender:nil];
                             }]
    ;
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)picker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
//    [self dismissModalViewControllerAnimated:YES];
    return YES;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)picker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (property == kABPersonPhoneProperty) {
                                     ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                                     for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
                                         if(identifier == ABMultiValueGetIdentifierAtIndex (multiPhones, i)) {
                                             CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                                             CFRelease(multiPhones);
                                             NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                                             CFRelease(phoneNumberRef);
                                             NSLog(@"...........phone number %@", phoneNumber);
                                             
                                             
                                             MFMessageComposeViewController *smscontroller = [MFMessageComposeViewController new];
                                             if([MFMessageComposeViewController canSendText])
                                             {
                                                 
                                                 
                                                 [EWImage shareImage:self.imageName
                                                              inWave:self.waveName
                                                             success:^(NSString *token) {

                                                                 
                                                                 smscontroller.body =
                                                                 [NSString
                                                                  stringWithFormat:@"I want to share Echowaves photo with you echowaves://share?token=%@", token];
                                                                 
                                                                 smscontroller.recipients = [NSArray arrayWithObjects: phoneNumber, nil];
                                                                 smscontroller.messageComposeDelegate = self;
                                                                 [self presentViewController:smscontroller animated:YES completion:^{
                                                                     NSLog(@"sms controller presented");
                                                                 }];
                    
                                                                 
                                                             } failure:^(NSError *error) {
                                                                 [EWDataModel showAlertWithMessage:[error description]
                                                                                        FromSender:nil];
                                                             }];
                                                 
                                             }
                                         }
                                     }
                                 }
                             
                             }];
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"dismissing people picker");
                             }];

}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			[EWImage showAlertWithMessage:@"Failed SMS" FromSender:nil];
			break;
		case MessageComposeResultSent:
            
			break;
		default:
			break;
	}
    
	
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed sms controller");
    }];
}

@end
