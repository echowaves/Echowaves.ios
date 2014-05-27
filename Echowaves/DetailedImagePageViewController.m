//
//  DetailedImagePageViewController.m
//  Echowaves
//
//  Created by Dmitry on 5/27/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "DetailedImagePageViewController.h"
#import "DetailedImageViewController.h"

@interface DetailedImagePageViewController ()

@end

@implementation DetailedImagePageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDictionary *options = [NSDictionary dictionaryWithObject:
                             [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                        forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc]
                       initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                       navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                       options: options];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    DetailedImageViewController *detailedImageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImageView"];
    
    NSDictionary *imageFromJson = [self.waveImages objectAtIndex:[self imageIndex]];
    
    detailedImageViewController.imageName = [imageFromJson objectForKey:@"name"];
    detailedImageViewController.waveName = [imageFromJson objectForKey:@"name_2"];

    
    NSArray *viewControllers =
    [NSArray arrayWithObject:detailedImageViewController];

    [self.pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    
}
- (DetailedImageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Return the data view controller for the given index.
    if (([self.waveImages count] == 0) ||
        (index >= [self.waveImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    /*
     ContentViewController *dataViewController =
     [[ContentViewController alloc] init];
     */
    
//    UIStoryboard *storyboard =
//    [UIStoryboard storyboardWithName:@"Main"
//                              bundle:[NSBundle mainBundle]];
//    
//    ContentViewController *dataViewController =
//    [storyboard
//     instantiateViewControllerWithIdentifier:@"contentView"];
//    
//    dataViewController.dataObject = _pageContent[index];

    DetailedImageViewController *detailedImageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImageView"];
    
    NSDictionary *imageFromJson = [self.waveImages objectAtIndex:index];
    
    detailedImageViewController.imageName = [imageFromJson objectForKey:@"name"];
    detailedImageViewController.waveName = [imageFromJson objectForKey:@"name_2"];
//    detailedImageViewController.waveImages = [self waveImages];

    
    return detailedImageViewController;
}

- (NSUInteger)indexOfViewController:(DetailedImageViewController *)viewController
{
    return [self imageIndex];
}

- (DetailedImageViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerBeforeViewController:
(UIViewController *)viewController
{
    if (([self imageIndex] == 0)) {
        return nil;
    }
    self.imageIndex--;
    return [self viewControllerAtIndex:[self imageIndex]];
}

- (UIViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([self imageIndex] == [self.waveImages count]) {
        return nil;
    }
    self.imageIndex++;
    return [self viewControllerAtIndex:[self imageIndex]];
}

@end
