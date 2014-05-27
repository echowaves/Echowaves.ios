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
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];

    self.currImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
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
    
    
    if( [self waveImages]) {
        self.imageIndex = [EWImage imageIndexFromImageName:[self imageName] waveName:[self waveName] waveImages:[self waveImages]];
        
        if( [self imageIndex] != -1) {
            if([self imageIndex] < [self.waveImages count]) {
                NSDictionary *nextImage = [[self waveImages] objectAtIndex:[self imageIndex] +1];
                NSString *nextImageName = [nextImage objectForKey:@"name"];
                NSString *nextWaveName = [nextImage objectForKey:@"name_2"];
                
                [EWImage loadThumbImage:nextImageName
                                forWave:nextWaveName
                                success:^(UIImage *image) {
                                    self.nextImageView.image = image;
                                    NSLog(@"loaded next image");
                                } failure:^(NSError *error) {
                                    self.nextImageView = nil;
                                    NSLog(@"failed loading next image");
                                }];
            }
            if([self imageIndex] > 0) {
                NSDictionary *prevImage = [[self waveImages] objectAtIndex:[self imageIndex] -1];
                NSString *prevImageName = [prevImage objectForKey:@"name"];
                NSString *prevWaveName = [prevImage objectForKey:@"name_2"];
                
                [EWImage loadThumbImage:prevImageName
                                forWave:prevWaveName
                                success:^(UIImage *image) {
                                    self.prevImageView.image = image;
                                    NSLog(@"loaded prev image");
                                } failure:^(NSError *error) {
                                    self.prevImageView = nil;
                                    NSLog(@"failed loading prev image");
                                }];
            }
        }
        
    }
    
    [EWImage loadThumbImage:[self imageName]
                    forWave:[self waveName]
                    success:^(UIImage *image) {
                        self.currImageView.image = image;
                        self.currImageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        [EWImage loadFullImage:[self imageName]
                                       forWave:[self waveName]
                                       success:^(UIImage *image) {
                                           [self.progressView setHidden:TRUE];
                                           
                                           self.currImageView.image = image;
                                           self.currImageView.contentMode = UIViewContentModeScaleAspectFit;
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
                    }];
    

}

- (CGRect)frameForPreviousViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(-self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForCurrentViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForNextViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}


- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    // transform the three views by the amount of the x translation
    
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0; // I'm just doing horizontal scrolling
    
    [self prevImageView].frame = [self frameForPreviousViewWithTranslate:translate];
    [self currImageView].frame = [self frameForCurrentViewWithTranslate:translate];
    [self nextImageView].frame = [self frameForNextViewWithTranslate:translate];
    
    // if we're done with gesture, animate frames to new locations
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed)
    {
        // figure out if we've moved (or flicked) more than 50% the way across
        
        CGPoint velocity = [gesture velocityInView:gesture.view];
        if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (gesture.view.bounds.size.width / 2.0) && [self prevImageView])
        {
            // moving right (and/or flicked right)
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self prevImageView].frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self currImageView].frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }
                             completion:^(BOOL finished) {
                                 // do whatever you want upon completion to reflect that everything has slid to the right
                                 
                                 // this redefines "next" to be the old "current",
                                 // "current" to be the old "previous", and recycles
                                 // the old "next" to be the new "previous" (you'd presumably.
                                 // want to update the content for the new "previous" to reflect whatever should be there
                                 
                                 UIImageView *tempView = [self nextImageView];
                                 self.nextImageView = [self currImageView];
                                 self.currImageView = [self prevImageView];
                                 self.prevImageView = tempView;
                                 [self prevImageView].frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                             }];
        }
        else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(gesture.view.frame.size.width / 2.0) && [self nextImageView])
        {
            // moving left (and/or flicked left)
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self nextImageView].frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self currImageView].frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                             }
                             completion:^(BOOL finished) {
                                 // do whatever you want upon completion to reflect that everything has slid to the left
                                 
                                 // this redefines "previous" to be the old "current",
                                 // "current" to be the old "next", and recycles
                                 // the old "previous" to be the new "next". (You'd presumably.
                                 // want to update the content for the new "next" to reflect whatever should be there
                                 
                                 UIImageView *tempView = [self prevImageView];
                                 self.prevImageView = [self currImageView];
                                 self.currImageView = [self nextImageView];
                                 self.nextImageView = tempView;
                                 [self nextImageView].frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }];
        }
        else
        {
            // return to original location
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self prevImageView].frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                                 [self currImageView].frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self nextImageView].frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }
                             completion:NULL];
        }
    }
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
    [EWImage saveImageToAssetLibrary:[self.currImageView image]
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


+(long)imageIndexFromName:(NSString *) imageName
               waveImages:(NSArray *) waveImages {
    
    
    return -1;
}

@end
