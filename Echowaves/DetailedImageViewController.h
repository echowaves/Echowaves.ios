//
//  DetailedImageViewController.h
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedImageViewController : UIViewController

@property (strong, nonatomic) NSDictionary *imageFromJson;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
