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
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        imagePickerController.allowsEditing = YES;
//        imagePickerController.wantsFullScreenLayout = YES;
        imagePickerController.edgesForExtendedLayout = UIRectEdgeAll;
        if(backfacing) {
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        self.imagePickerController = imagePickerController;
        
        UIResponder<UIApplicationDelegate> *appDelegate= [[UIApplication sharedApplication] delegate];
        [appDelegate.window addSubview:imagePickerController.view];
        //[self.navigationController pushViewController:imagePickerController animated:NO];
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
    
    //adjust waving to on
//    [APP_DELEGATE.wavingViewController.waving setOn:TRUE];
//    [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
//    [appDelegate.wavingViewController appStatus].text = @"Use iPhone cam, then come back to EW...";

//    [USER_DEFAULTS setBool:APP_DELEGATE.wavingViewController.waving.on forKey:@"waving"];
    [USER_DEFAULTS synchronize];

    //if(!mDidFinishWCamera)
    {
		if(![self showImagePicker:UIImagePickerControllerSourceTypeCamera backfacing:NO]) {
			[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary backfacing:NO];
		}
	}

}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (error)
    {
        NSLog(@"image save completed with %@/%@", error, contextInfo);
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate pictureSaved];
                    [APP_DELEGATE.wavingViewController updatePhotosCount];
        });
    }
    [self.imagePickerController.view removeFromSuperview];
}

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else{
        [picker.view removeFromSuperview];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"camera cancelled");
    [picker.view removeFromSuperview];
}

@end
