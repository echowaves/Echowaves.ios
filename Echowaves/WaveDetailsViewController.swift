//
//  WaveDetailsViewController.swift
//  Echowaves
//
//  Created by D on 12/6/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class WaveDetailsViewController : UIViewController, UIAlertViewDelegate {
    @IBOutlet var waveName:UILabel!
    @IBOutlet var deleteWaveButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.waveName.text! = APP_DELEGATE.currentWaveName
        
        EWWave.getWaveDetails(
            self.waveName.text!,
            success: { (waveDetails) -> () in
                if waveDetails.objectForKey("parent_wave_id") != nil {
                    self.navigationItem.rightBarButtonItem =
                        UIBarButtonItem(
                            barButtonSystemItem: UIBarButtonSystemItem.Trash,
                            target: self,
                            action: "deleteWave:")
                } else {
                    self.deleteWaveButton.hidden = true
                }
            },
            failure: { (errorMessage) -> () in
                EWWave.showErrorAlertWithMessage(errorMessage,  fromSender:self)
        })
    }
    
    @IBAction func deleteWave(sender: AnyObject?) {
    EWWave.showAlertWithMessageAndCancelButton("Will remove wave and all it's photos. Sure?",
        okAction: { (UIAlertAction) -> Void in
            EWWave.deleteChildWave(self.waveName.text!,
                success: { (waveName) -> () in
                    APP_DELEGATE.currentWaveName = ""// this will be an indicator for the wavingViewController to reload and reinitialize the proper waveName
                    self.navigationController?.popViewControllerAnimated(true)
                },
                failure: { (errorMessage) -> () in
                    EWWave.showErrorAlertWithMessage(errorMessage, fromSender:self)
                    self.navigationController?.popViewControllerAnimated(true)
            })
            
        },
        fromSender: self)
    }
}