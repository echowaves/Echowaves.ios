//
//  DetailedImageViewController.m
//  Echowaves
//
//  Created by Dmitry on 2/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "DetailedImageViewController.h"
#import "EWImage.h"

@implementation DetailedImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"###########imageFromJson %@", self.imageFromJson);
    
    NSString* imageName = [self.imageFromJson objectForKey:@"name"];
    NSString* waveName = [self.imageFromJson objectForKey:@"name_2"];
//    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/%@", EWHost, waveName, imageName];
    
    [EWDataModel showLoadingIndicator:self];

    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
                          [EWDataModel hideLoadingIndicator:self];

                          self.imageView.image = image;
                          
                          self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                      }
                      failure:^(NSError *error) {
                          [EWDataModel showErrorAlertWithMessage:@"Error Loading image" FromSender:self];

                          NSLog(@"error: %@", error.description);
                      }];
    
}


@end
