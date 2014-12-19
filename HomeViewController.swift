//
//  HomeViewController.swift
//  Echowaves
//
//  Created by D on 11/18/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    //    required init(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    
    @IBOutlet weak var firstTimeLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var createNewWaveButton: UIButton!
    

    @IBOutlet weak var waveName:UITextField!
    @IBOutlet weak var wavePassword:UITextField!
    @IBOutlet weak var tuneInButton:UIButton!

    
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
        if let credential:NSURLCredential = EWWave.getStoredCredential() {
            
            NSLog("$$$$$$$$$$$$$$$$User \(credential.user) already connected with password.")
            NSLog("~~~~~~~~~~~~~~~~~~~~~~ preparing to sign in")
            EWWave.showLoadingIndicator(self)
            EWWave.tuneIn( credential.user!,
                wavePassword: credential.password!,
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
        
        self.waveName.delegate = self
        
        tuneInButton.layer.cornerRadius = 4.0
        createNewWaveButton.layer.cornerRadius = 4.0
        
        
        tuneInButton.layer.cornerRadius = 4.0
        tuneInButton.layer.borderWidth = 1.0
        tuneInButton.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        waveName.layer.cornerRadius = 4.0
        waveName.layer.borderWidth = 1.0
        waveName.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        wavePassword.layer.cornerRadius = 4.0
        wavePassword.layer.borderWidth = 1.0
        wavePassword.layer.borderColor = UIColor(rgb:0xFFA500).CGColor;

    }

    override func viewWillAppear(animated: Bool) {
        if let credential = EWWave.getStoredCredential() {
            NSLog("User \(credential.user) already connected with password.")
            self.waveName.text = credential.user
            self.wavePassword.text = credential.password
            
            hideTextIfNecessery()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        NSLog("+++++++++textFieldDidEndEditing: \(textField.text.utf16Count)")
        hideTextIfNecessery()
    }
    
    func hideTextIfNecessery() -> Void {
        if self.waveName.text.utf16Count > 0 {
            self.firstTimeLabel.hidden = true
            self.questionLabel.hidden = true
            self.createNewWaveButton.hidden = true
        } else {
            self.firstTimeLabel.hidden = false
            self.questionLabel.hidden = false
            self.createNewWaveButton.hidden = false
        }
    }
    
    @IBAction func tuneIn(sender:UIButton) {
        let waveName = self.waveName.text
        let wavePassword = self.wavePassword.text
        if(waveName.utf16Count == 0 || wavePassword.utf16Count == 0) {
            EWWave.showErrorAlertWithMessage("Both fields are required", fromSender: self)
            return
        }
        NSLog("-------calling tuneIn")
        EWWave.showLoadingIndicator(self)
        
        
        EWWave.tuneIn(waveName,
            wavePassword: wavePassword,
            success: { (waveName) -> () in
                EWWave.hideLoadingIndicator(self)
                EWWave.storeCredential(waveName, wavePassword: wavePassword)
                
                if APP_DELEGATE.deviceToken != "" {
                    EWWave.storeIosToken(waveName, token: APP_DELEGATE.deviceToken,
                        success: { (waveName) -> () in
                            NSLog("stored device token for: \(waveName)")
                        },
                        failure: { (errorMessage) -> () in
                            NSLog("failed storing deviceToken \(errorMessage)")
                    })
                }
                self.performSegueWithIdentifier("TuneIn", sender: self)
                
            },
            failure: { (errorMessage) -> () in
                EWWave.hideLoadingIndicator(self)
                EWWave.showErrorAlertWithMessage(errorMessage, fromSender: self)
        })
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("----------------seguiing")
        
        // Make sure your segue name in storyboard is the same as this line
        if (segue.identifier == "TuneIn")
        {
            NSLog("----calling prepareForSegue TuneIn")
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        NSLog("----calling shouldPerformSegueWithIdentifier TuneIn");
        
        if (identifier == "TuneIn") {
            return false
        }
        return true
    }

    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if(textField.tag==1) {
//            wavePassword.becomeFirstResponder()
//        }else{
//            textField.resignFirstResponder()
//            self.tuneIn(tuneInButton)
//        }
//        return true
//    }

    
}
    