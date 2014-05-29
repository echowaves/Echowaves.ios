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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageScrollView.delegate = self;
    self.imageScrollView.minimumZoomScale = 1.0;
    self.imageScrollView.maximumZoomScale = 100.0;
    self.progressView.progress = 0.0;
    self.progressView.hidden = TRUE;

    [self initView];
    
    UITapGestureRecognizer *tapOnce =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapOnce:)];
    UITapGestureRecognizer *tapTwice =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapTwice:)];
    
    tapOnce.numberOfTapsRequired = 1;
    tapTwice.numberOfTapsRequired = 2;
    
    //stops tapOnce from overriding tapTwice
    [tapOnce requireGestureRecognizerToFail:tapTwice];
    
    // then need to add the gesture recogniser to a view
    // - this will be the view that recognises the gesture
    [self.view addGestureRecognizer:tapOnce];
    [self.view addGestureRecognizer:tapTwice];

}
- (void)loadFullImage {
    self.progressView.hidden = FALSE;
    self.fullSizeImageLoaded=YES;
    [EWImage loadFullImage:[self imageName]
                   forWave:[self waveName]
                   success:^(UIImage *image) {
                       self.imageView.image = image;
                       self.progressView.hidden = TRUE;
                   }
                   failure:^(NSError *error) {
                       self.progressView.hidden = TRUE;
                       [EWDataModel showErrorAlertWithMessage:@"Error Loading full image" FromSender:nil];
                       NSLog(@"error: %@", error.description);
                       self.fullSizeImageLoaded=NO;
                   }
                  progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                      self.progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                  }];
}

- (void)tapOnce:(UIGestureRecognizer *)gesture
{
    if(self.navigationController.navigationBarHidden) {
        if(![self fullSizeImageLoaded]) {
            [self loadFullImage];
        } else {
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
        }
    } else {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        if(![self fullSizeImageLoaded]) {
            [self loadFullImage];
        }
    }
}

- (void)tapTwice:(UIGestureRecognizer *)gesture
{
    CGPoint point = [(UITapGestureRecognizer *)gesture locationInView:[self imageView]];
    CGRect rectToZoomOutTo = CGRectMake(point.x, point.y, self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
    [self.imageScrollView zoomToRect:rectToZoomOutTo animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateView];
}

//- (void) viewWillDisappear:(BOOL)animated {
//    self.navItem = nil;
//}

- (void) initView {
//    self.currImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSLog(@",,,,,,,,,,,,,,,,,,,,,,,%@/%@", [self waveName], [self imageName]);
    [EWImage loadThumbImage:[self imageName]
                    forWave:[self waveName]
                    success:^(UIImage *image) {
                        self.imageView.image = image;
                        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        [self.imageView sizeToFit];
                        self.imageScrollView.contentSize = image.size;
                    }
                    failure:^(NSError *error) {
                        [EWDataModel showErrorAlertWithMessage:@"Error Loading thumb image" FromSender:nil];
                        NSLog(@"error: %@", error.description);
                    }];
    
}
- (void) updateView {
    [self navItem].rightBarButtonItems = nil;
    
    [[self waveNameLable] setText:[self waveName]];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat : @"yyyyMMddHHmmssSSSS"];
    NSString *dateString = [self.imageName substringWithRange:NSMakeRange(0, 18)];
    NSLog(@"imageName  = %@", self.imageName);
    NSLog(@"dateString = %@", dateString);
    NSDate *dateTime = [formatter dateFromString:dateString];
    
    //    [formatter release];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [self.navItem setTitle:[formatter stringFromDate:dateTime]];
    
    //    [[self navigationItem].backBarButtonItem setTitle:@" "];
    
    if ([self.waveName isEqualToString:[APP_DELEGATE currentWaveName]]) {
        
        UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(deleteImage)];
        
        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(shareImage)];
        
        [self navItem].rightBarButtonItems = @[shareButton, deleteButton];
    } else {
        [self navItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                          target:self
                                                                                          action:@selector(saveImage)];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


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
