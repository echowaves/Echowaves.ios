//
//  DetailedImageViewController.h
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedImageViewController : UIViewController

@property (weak, nonatomic) NSDictionary *imageFromJson;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end
