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
        APP_DELEGATE.wavingViewController.takepicture()
    }
    
    @IBAction func pushUpload(sender: AnyObject?) {
        NSLog("pushing upload")
        APP_DELEGATE.checkForInitialViewToPresent()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}