//
//  EchowavesImagePickerController.h
//  Echowaves
//
//  Created by Anton Tropashko on 3/7/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EchowavesImagePickerControllerProtocol <NSObject>

-(void)pictureSaved;

@end
@interface EchowavesImagePickerController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, weak) id<EchowavesImagePickerControllerProtocol> delegate;
-(IBAction)takepicture;
@end
