//
//  AddChildWaveViewController.swift
//  Echowaves
//
//  Created by D on 12/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class AddChildWaveViewController:UIViewController {
    
    @IBOutlet var childWaveName:UITextField!
    @IBOutlet var createChildWave:UIButton!
    
    @IBAction func createChildWave(sender: AnyObject?) {
        
                EWWave.createChildWave(
                    self.childWaveName!.text,
                    success: { (newWaveName) -> Void in
                        if let navController = self.navigationController {
                            navController.popViewControllerAnimated(true)
                        }
                    },
                    failure:{ (errorMessage) -> Void in
                        EWWave.showErrorAlertWithMessage(errorMessage, fromSender: self)
                        self.navigationController?.popViewControllerAnimated(true)
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createChildWave.layer.cornerRadius = 4.0
        self.createChildWave.layer.borderWidth = 1.0
        self.createChildWave.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
        
        self.childWaveName.layer.cornerRadius = 4.0
        self.childWaveName.layer.borderWidth = 1.0
        self.childWaveName.layer.borderColor = UIColor(rgb:0xFFA500).CGColor
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        self.childWaveName.becomeFirstResponder()
        self.childWaveName.text = "\(APP_DELEGATE.currentWaveName)."
    }
    
}
