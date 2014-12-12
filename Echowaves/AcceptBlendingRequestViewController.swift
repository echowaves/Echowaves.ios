//
//  AcceptBlendingRequestViewController.swift
//  Echowaves
//
//  Created by D on 12/11/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation


class AcceptBlendingRequestViewController : UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var blendWaveLabel:UILabel!
    @IBOutlet var fromWaveLabel:UILabel!
    @IBOutlet var toWaveLabel:UILabel!
    
    
    @IBOutlet var wavesPicker:UIPickerView!
    
    var fromWave = ""
    var toWave = ""
    var origToWave = ""
    
    var myWaves = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateLabels()
        self.reloadWaves()
    }
    
    func updateLabels() -> Void {
        self.fromWaveLabel.text = self.fromWave
        self.toWaveLabel.text = self.toWave
        self.blendWaveLabel.text = "You will be able to see \(self.fromWave)'s photos blended with your wave \(self.toWave). Your \(self.toWave)'s photos will be visible to \(self.fromWave) as well"
        NSLog("xxxxxxxxx blend wave text \(self.fromWave)")
    }
    
    func reloadWaves() -> Void {
        EWWave.getAllMyWaves(
            { (waves) -> () in
                self.myWaves = waves
                
                if APP_DELEGATE.currentWaveName == "" {
                    if let credential = EWWave.getStoredCredential() {
                        APP_DELEGATE.currentWaveName = credential.user!
                        APP_DELEGATE.currentWaveIndex = 0
                    }
                }
                self.navigationController?.navigationBar.topItem?.title = ""//[APP_DELEGATE currentWaveName];
                
                self.reloadWavesPicker()
                self.wavesPicker.selectRow(APP_DELEGATE.currentWaveIndex, inComponent: 0, animated: true)
            },
            failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
        })
    }
    
    func reloadWavesPicker() -> Void {
        self.wavesPicker.reloadAllComponents()
    }
    
    
    @IBAction func cancelAction(sender: AnyObject!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func acceptAction(sender: AnyObject!) {
        NSLog("called pickAWave POP")
        EWBlend.showLoadingIndicator(self)
        
        NSLog("origToWave:\(self.origToWave) toWave:\(self.toWave) fromWave:\(self.fromWave)")
        
        EWBlend.acceptBlending(
            self.origToWave,
            myWaveName: self.toWave,
            friendWaveName: self.fromWave,
            success: { () -> () in
                EWBlend.hideLoadingIndicator(self)
                self.navigationController?.popViewControllerAnimated(true)
            }, failure: { (error) -> () in
                EWBlend.hideLoadingIndicator(self)
                EWBlend.showAlertWithMessage("Blending failed", fromSender: self)
                NSLog("failed blending \(error.debugDescription)")
                self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //    NSLog(@"^^^^^^^^^^^^number of child waves: %lu", (unsigned long)[self myWaves].count);
        return self.myWaves.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        //    NSLog(@"redrawing row: %ld", (long)row);
        let subView = UIView()
        subView.backgroundColor = UIColor.orangeColor()
        
        let name = UILabel()
        name.textColor = UIColor.darkTextColor()
        name.font = UIFont(name: "Trebuchet MS", size: 14.0)
        name.text = ((self.myWaves[row] as NSDictionary).objectForKey("name") as String)
        name.textAlignment = NSTextAlignment.Right
        name.frame = CGRectMake(10, 0, 230, 30)
        
        subView.addSubview(name)
        
        return subView
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog(",,,,,,,,,,,,,,,,,,, did select row: \(row)")
        APP_DELEGATE.currentWaveName = ((self.myWaves[row] as NSDictionary).objectForKey("name") as String)
        APP_DELEGATE.currentWaveIndex = row
        //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
        
        //    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        self.toWave = APP_DELEGATE.currentWaveName
        self.updateLabels()
        //    [self reloadWavesPicker];
    }
    
}