//
//  DetailedImagePageViewController.h
//  Echowaves
//
//  Created by Dmitry on 5/27/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedImagePageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

//following 2 properties must be always set for the view to work correctly (flipping through images)
@property (strong, atomic) NSArray *waveImages;
@property (atomic) NSUInteger initialViewIndex;

@property (strong, nonatomic) UIPageViewController *pageController;

@end
