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
    
    [self setTitle:@"Detailed Image"];
    [self.navigationItem setPrompt:[NSString stringWithFormat:@"Image Date %@", @"qweqwe"]];

    
//    NSLog(@"###########imageFromJson %@", self.imageFromJson);
    
    NSString* imageName = [self.imageFromJson objectForKey:@"name"];
    NSString* waveName = [self.imageFromJson objectForKey:@"name_2"];
//    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/%@", EWHost, waveName, imageName];
    
//    [EWDataModel showLoadingIndicator:self];
    self.progressView.progress = 0.0;
    [self.progressView setHidden:FALSE];
    
    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
//                          [EWDataModel hideLoadingIndicator:self];
                          self.imageView.image = image;
                          self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                          [self.progressView setHidden:TRUE];
                      }
                      failure:^(NSError *error) {
                          [EWDataModel showErrorAlertWithMessage:@"Error Loading image" FromSender:self];

                          NSLog(@"error: %@", error.description);
                      }
                     progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                         self.progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                     }];
    
}


@end
