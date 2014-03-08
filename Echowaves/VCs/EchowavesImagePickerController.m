//
//  EchowavesImagePickerController.m
//  Echowaves
//
//  Created by Anton Tropashko on 3/7/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "EchowavesImagePickerController.h"

@interface EchowavesImagePickerController ()
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@end

@implementation EchowavesImagePickerController

- (BOOL)showImagePicker:(UIImagePickerControllerSourceType)sourceType
                   backfacing:(BOOL)backfacing
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
//        self.imagePickerController.showsCameraControls = YES;
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.sourceType = sourceType;
        self.imagePickerController.wantsFullScreenLayout = YES;
        self.imagePickerController.delegate = self;
        if(backfacing) {
			self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		}
        UIViewController *vc =self;
        NSLog(@"sip vc %@", vc);
		[vc presentViewController:self.imagePickerController animated:YES
                         completion:nil];
		return YES;
    }
	return NO;
}

- (IBAction)photoLibraryAction:(id)sender
{
	[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary
                     backfacing:NO];
}

-(IBAction)takepicture
{
    //if(!mDidFinishWCamera)
    {
		if(![self showImagePicker:UIImagePickerControllerSourceTypeCamera backfacing:NO]) {
			[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary backfacing:NO];
		}
	}
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        // Get the selected Video.
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        // Convert to Video data.
        NSData *imageData = [NSData dataWithContentsOfURL:videoURL];
        
        // Save Video to Photo Album
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:recordedVideoURL]) {
            [library writeImageDataToSavedPhotosAlbum:imageData metadata:info completionBlock:^(NSURL *assetURL, NSError *error)
             {
             }
             ];
        }
    }
    [self.imagePickerController dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
    [self.imagePickerController dismissViewControllerAnimated:NO completion:nil];
}


@end
