//
//  SignInViewController.swift
//  Echowaves
//
//  Created by D on 11/19/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var waveName:UITextField!
    @IBOutlet weak var wavePassword:UITextField!
    @IBOutlet weak var tuneInButton:UIButton!
    
    
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
                
                if let deviceToken = (UIApplication.sharedApplication().delegate  as EchowavesAppDelegate).deviceToken {
                    EWWave.storeIosToken(waveName, token: deviceToken,
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let credential = EWWave.getStoredCredential() {
            NSLog("User \(credential.user) already connected with password.")
            self.waveName.text = credential.user
            self.wavePassword.text = credential.password
        }
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField.tag==1) {
            wavePassword.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            self.tuneIn(tuneInButton)
        }
        return true
    }
    
    
}