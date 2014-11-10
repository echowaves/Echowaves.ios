//
//  DetailedImageViewController.m
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "Echowaves-Swift.h"
#import "DetailedImageViewController.h"

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

- (IBAction)loadFullImage:(id)sender {
    self.progressView.hidden = FALSE;
    self.fullSizeImageLoaded=YES;
    self.highQualityButton.hidden = YES;
    
    [EWImage loadFullImage:[self imageName]
                  waveName:[self waveName]
                   success:^(UIImage *image) {
                       self.imageView.image = image;
                       self.progressView.hidden = TRUE;
                   }
                   failure:^(NSError *error) {
                       self.progressView.hidden = TRUE;
                       [EWDataModel showErrorAlertWithMessage:@"Error Loading full image" fromSender:nil];
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
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        self.waveNameLable.hidden = NO;
        
    } else {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        self.waveNameLable.hidden = YES;
    }
}

- (void)tapTwice:(UIGestureRecognizer *)gesture
{
    CGPoint point = [(UITapGestureRecognizer *)gesture locationInView:[self imageView]];
    CGRect rectToZoomOutTo = CGRectMake(point.x/2, point.y/2, self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
    [self.imageScrollView zoomToRect:rectToZoomOutTo animated:YES];
}

//-(BOOL) shouldAutorotate {
//    return YES;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateView];
}

//- (void) viewWillDisappear:(BOOL)animated {
//    self.navItem = nil;
//}

- (void) initView {
    //    self.currImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSLog(@",,,,,,,,,,,,,,,,,,,,,,,%@/%@", [self waveName], [self imageName]);
    [EWImage loadThumbImage:[self imageName]
                   waveName:[self waveName]
                    success:^(UIImage *image) {
                        self.imageView.image = image;
                        //                        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        //                        [self.imageView sizeToFit];
                        self.imageScrollView.contentSize = image.size;
                    }
                    failure:^(NSError *error) {
                        [EWDataModel showErrorAlertWithMessage:@"Error Loading thumb image" fromSender:nil];
                        NSLog(@"error: %@", error.description);
                    }
                   progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                   }
     ];
    
}

- (void) updateView {
    if(self.navigationController.navigationBarHidden) {
        self.waveNameLable.hidden = YES;
    } else {
        self.waveNameLable.hidden = NO;
    }
    
    
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
    
    //        [[self navigationItem].backBarButtonItem setTitle:@" qwe"];
    
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
    
    
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    
    if (accessGranted) {
        ABPeoplePickerNavigationController *peoplePicker = [ABPeoplePickerNavigationController new];
        peoplePicker.peoplePickerDelegate = self;
        //    peoplePicker.modalPresentationStyle =
        [self presentViewController:peoplePicker animated:YES completion:^{
            NSLog(@"done presenting");
        }];
    } else {
        [EWImage showAlertWithMessage:@"Enable access to contacts for Echowaves in preferences" fromSender:self];
    }
    
    
    
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {//OK button clicked, let's delete the wave
        [EWImage showLoadingIndicator:self];
        [EWImage deleteImage:[(DeleteImageAlertView*)alertView imageName]
                      waveName:[(DeleteImageAlertView*)alertView waveName]
                     success:^{
                         [self.navigationController popViewControllerAnimated:YES];
                         [EWImage hideLoadingIndicator:self];
                     }
                     failure:^(NSError *error) {
                         [EWImage hideLoadingIndicator:self];
                         [EWImage showErrorAlertWithMessage:@"Unable to delete image" fromSender:nil];
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
        
    }
}


-(void)saveImage {
    [EWImage saveImageToAssetLibrary:[self.imageView image]
                             success:^{
                                 [EWDataModel showAlertWithMessage:@"Photo Saved to iPhone"
                                                        fromSender:nil];
                             }
                             failure:^(NSError *error) {
                                 [EWDataModel showErrorAlertWithMessage:@"Error saving" fromSender:nil];
                             }]
    ;
}


//- (void)peoplePickerNavigationController:
//(ABPeoplePickerNavigationController *)picker
//      didSelectPerson:(ABRecordRef)person
//{
//    NSLog(@"did select person");
////    [self dismissModalViewControllerAnimated:YES];
////    return YES;
//}


- (void)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)picker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    NSLog(@"did select person property");
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
                                             //                                             NSLog(@"...........phone number %@", phoneNumber);
                                             
                                             
                                             MFMessageComposeViewController *smscontroller = [MFMessageComposeViewController new];
                                             if([MFMessageComposeViewController canSendText])
                                             {
                                                 
                                                 
                                                 [EWImage shareImage:self.imageName
                                                              waveName:self.waveName
                                                             success:^(NSString *token) {
                                                                 
                                                                 smscontroller.recipients = [NSArray arrayWithObjects: phoneNumber, nil];
                                                                 smscontroller.messageComposeDelegate = self;
                                                                 smscontroller.body = [NSString stringWithFormat:@"Look at my photo and blend with my wave http://echowaves.com/mobile?token=%@", token];
                                                                 
                                                                 [self presentViewController:smscontroller animated:YES completion:^{
                                                                     
                                                                     NSLog(@"sms controller presented");
                                                                 }];
                                                                 
                                                                 
                                                             } failure:^(NSError *error) {
                                                                 [EWDataModel showAlertWithMessage:[error description]
                                                                                        fromSender:nil];
                                                             }];
                                                 
                                             }
                                         }
                                     }
                                 }
                                 
                             }];
    
    NSLog(@"returning from people picker");
    //    return YES;
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
            [EWImage showAlertWithMessage:@"Failed SMS" fromSender:nil];
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
