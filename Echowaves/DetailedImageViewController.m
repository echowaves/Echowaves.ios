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
    
    [self.navigationItem setPrompt:waveName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"yyyyMMddHHmmssSSSS"];
    NSString *dateString = [imageName substringWithRange:NSMakeRange(0, 18)];
    NSLog(@"imageName  = %@", imageName);
    NSLog(@"dateString = %@", dateString);
    NSDate *dateTime = [formatter dateFromString:dateString];
    
//    [formatter release];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [self setTitle:[formatter stringFromDate:dateTime]];

    
    
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
