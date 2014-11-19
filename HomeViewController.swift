//
//  HomeViewController.swift
//  Echowaves
//
//  Created by D on 11/18/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {

//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    

    @IBOutlet weak var tuneInButton: UIButton!
    @IBOutlet weak var createNewWaveButton: UIButton!
    
    
    @IBAction func backToHomeViewController (segue : UIStoryboardSegue) {
            NSLog("from segue id: \(segue.identifier)")
            EWWave.tuneOut()
    }

    

    override func viewDidLoad() {
    super.viewDidLoad()
        
        let backButton: UIBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        
    self.navigationItem.backBarButtonItem  = backButton
    
    //user is signed in before
    //try to sign in to see if connection is awailable
        let credential:NSURLCredential? = EWWave.getStoredCredential()
    if((credential) != nil) {
    NSLog("$$$$$$$$$$$$$$$$User \(credential?.user) already connected with password.")
    NSLog("~~~~~~~~~~~~~~~~~~~~~~ preparing to sign in")
    EWWave.showLoadingIndicator(self)
    EWWave.tuneIn( credential!.user!,
        wavePassword: credential!.password!,
        success: { (waveName) -> () in
            EWWave.hideLoadingIndicator(self)
            self.performSegueWithIdentifier("AutoSignIn", sender: self)
        },
        failure: { (errorMessage) -> () in
            EWWave.hideLoadingIndicator(self)
            EWWave.showErrorAlertWithMessage(errorMessage, fromSender: self)
    })
        
    
    } else { // credentials are not set, can't really ever happen, something is really wrong here
    NSLog("this error should never happen credentials are not set, can't really ever happen, something is really wrong here")
    }
    
    tuneInButton.layer.cornerRadius = 4.0
    createNewWaveButton.layer.cornerRadius = 4.0
    }
    
}
    