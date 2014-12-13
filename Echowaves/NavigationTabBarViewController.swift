//
//  NavigationTabBarViewController.swift
//  Echowaves
//
//  Created by D on 11/19/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class NavigationTabBarViewController : UITabBarController {
    
    @IBAction func takePicture(sender: AnyObject?) {
        NSLog("taking picture")
        
        self.selectedIndex = 1 // select waving controller
        APP_DELEGATE.wavingViewController!.takePicture(self)
    }
    
    
    
//    @IBAction func pushUpload(sender: AnyObject?) {
//        NSLog("pushing upload")
//        APP_DELEGATE.checkForInitialViewToPresent()
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        APP_DELEGATE.checkForInitialViewToPresent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APP_DELEGATE.navController = self.navigationController
    }
}