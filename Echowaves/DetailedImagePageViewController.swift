//
//  DetailedImagePageViewController.swift
//  Echowaves
//
//  Created by D on 11/19/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class DetailedImagePageViewController : UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    //following 2 properties must be always set for the view to work correctly (flipping through images)
    var waveImages = []
    var initialViewIndex:UInt = 0
    var pageController:UIPageViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let options = [UIPageViewControllerOptionSpineLocationKey: UIPageViewControllerSpineLocation.Min.rawValue]
        
        self.pageController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
            navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
            options: options)
        
        
        self.pageController?.dataSource = self
        self.pageController?.view.frame = self.view.bounds
        
        let detailedImageViewController:DetailedImageViewController = self.viewControllerAtIndex(self.initialViewIndex)!
        
        let viewControllers = [detailedImageViewController]
        
        self.pageController?.setViewControllers(viewControllers,
            direction: UIPageViewControllerNavigationDirection.Forward,
            animated: false,
            completion: nil)
        
        
        self.addChildViewController(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        self.pageController!.didMoveToParentViewController(self)
        self.viewControllerAtIndex(self.initialViewIndex)
        
    }
    
    
    
    
    func viewControllerAtIndex(index:UInt) -> (DetailedImageViewController?) {
        // Return the data view controller for the given index.
        if (self.waveImages.count == 0 || (Int(index) >= self.waveImages.count)) {
            return nil
        }
        
        let detailedImageViewController = UIStoryboard(name: "Main_iPhone", bundle:nil).instantiateViewControllerWithIdentifier("DetailedImageView") as DetailedImageViewController
        
        let imageFromJson:NSDictionary = self.waveImages[Int(index)] as NSDictionary
        
        detailedImageViewController.imageName = imageFromJson.objectForKey("name") as String
        detailedImageViewController.waveName = imageFromJson.objectForKey("name_2") as String
        detailedImageViewController.imageIndex = index
        
        detailedImageViewController.navItem? = self.navigationItem;
        
        return detailedImageViewController;
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as DetailedImageViewController).imageIndex
        
        if ((index == 0) || (Int(index) == NSNotFound)) {
            return nil
        }
        index--
        return viewControllerAtIndex(index)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as DetailedImageViewController).imageIndex
        if (Int(index) == NSNotFound) {
            return nil
        }
        index++
        if(Int(index) == self.waveImages.count) {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    
    
}
