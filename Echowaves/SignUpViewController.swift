//
//  SignUpViewController.swift
//  Echowaves
//
//  Created by D on 11/19/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var waveName:UITextField!
    @IBOutlet weak var wavePassword:UITextField!
    @IBOutlet weak var confirmPassword:UITextField!
    @IBOutlet weak var createWaveButton:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("------------viewDidLoad")
        
        waveName.layer.cornerRadius = 4.0
        waveName.layer.borderWidth = 1.0
        waveName.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        wavePassword.layer.cornerRadius = 4.0
        wavePassword.layer.borderWidth = 1.0
        wavePassword.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        confirmPassword.layer.cornerRadius = 4.0
        confirmPassword.layer.borderWidth = 1.0
        confirmPassword.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        createWaveButton.layer.cornerRadius = 4.0
        createWaveButton.layer.borderWidth = 1.0
        createWaveButton.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
    }
    
    
    
    
    @IBAction func createWave(sender: UIButton ) {
        let waveName = self.waveName.text
        let wavePassword = self.wavePassword.text
        let confirmPassword = self.confirmPassword.text
        if(waveName.utf16Count==0 || wavePassword.utf16Count==0 || confirmPassword.utf16Count==0) {
            
            EWDataModel.showAlertWithMessage("All fields are required", fromSender: self)
            return
        }
        NSLog("-------calling createWave")
        EWWave.showLoadingIndicator(self)
        EWWave.createWave(waveName,
            wavePassword: wavePassword,
            confirmPassword: confirmPassword,
            success: { (waveName) -> () in
                EWWave.hideLoadingIndicator(self)
                EWWave.storeCredential(waveName, wavePassword: wavePassword)
                
                if let deviceToken = (UIApplication.sharedApplication().delegate  as EchowavesAppDelegate).deviceToken {
                    EWWave.storeIosToken(waveName,
                        token: deviceToken,
                        success: { (waveName) -> () in
                            NSLog("stored device token for: \(waveName)")
                        },
                        failure: { (errorMessage) -> () in
                            NSLog("failed storing deviceToken \(errorMessage)")
                    })
                }
                self.performSegueWithIdentifier("CreateWave", sender: self)
            },
            failure: { (errorMessage) -> () in
                EWWave.hideLoadingIndicator(self)
                EWWave.showErrorAlertWithMessage(errorMessage, fromSender: self)
        })
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("----------------seguiing")
        
        // Make sure your segue name in storyboard is the same as this line
        if (segue.identifier == "CreateWave")
        {
            NSLog("----calling prepareForSegue CreateWave")
            //        navigationTabBarViewController.waveName.title = self.waveName.text;
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        NSLog("----calling shouldPerformSegueWithIdentifier CreateWave")
        
        if (identifier == "CreateWave") {
            return false
        }
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch(textField.tag)
        {
        case 0:
            wavePassword.becomeFirstResponder()
        case 1:
            confirmPassword.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            self.createWave(createWaveButton)
        }
        return true
    }
    
    
}