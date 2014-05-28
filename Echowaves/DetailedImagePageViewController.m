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
    
    DetailedImageViewController *detailedImageViewController = [self viewControllerAtIndex:[self initialViewIndex]];
    
    NSArray *viewControllers =
    [NSArray arrayWithObject:detailedImageViewController];

    [self.pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [self viewControllerAtIndex:[self initialViewIndex]];
    
}
- (DetailedImageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Return the data view controller for the given index.
    if (([self.waveImages count] == 0) ||
        (index >= [self.waveImages count])) {
        return nil;
    }
    
    DetailedImageViewController *detailedImageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImageView"];
    
    NSDictionary *imageFromJson = [self.waveImages objectAtIndex:index];
    
    detailedImageViewController.imageName = [imageFromJson objectForKey:@"name"];
    detailedImageViewController.waveName = [imageFromJson objectForKey:@"name_2"];
    detailedImageViewController.imageIndex = index;
    
    detailedImageViewController.navItem = self.navigationItem;

    return detailedImageViewController;
}

//- (NSUInteger)indexOfViewController:(DetailedImageViewController *)viewController
//{
//    return [self imageIndex];
//}

- (DetailedImageViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerBeforeViewController:
(UIViewController *)viewController
{
    NSUInteger index = ((DetailedImageViewController*) viewController).imageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DetailedImageViewController*) viewController).imageIndex;

    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if(index == [self.waveImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    
//}

//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
//    if(completed == YES) {
//        self.imageIndex = [self transitionIndex];
//    }
//}


@end
