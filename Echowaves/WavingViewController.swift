//
//  WavingViewController.swift
//  Echowaves
//
//  Created by D on 11/30/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class WavingViewController:
    EchowavesImagePickerController,
    EchowavesImagePickerControllerProtocol,
    UIGestureRecognizerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UITextFieldDelegate
{
    
//    @IBOutlet var photoButton:UIButton!
    @IBOutlet var waveSelected:UITextField!
    @IBOutlet var wavesPicker:UIPickerView!
    @IBOutlet var sinceDateTime:UIButton!
    
    var myWaves = []
//    var checkedAtload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APP_DELEGATE.wavingViewController = self
        self.delegate = self
    }
    
    
    func reloadWavesPicker() -> Void {
        EWWave.getAllMyWaves(
            { (waves) -> () in
                self.myWaves = waves;
                
                NSLog("11111111111 currentWaveName: \(APP_DELEGATE.currentWaveName)")
                
                if APP_DELEGATE.currentWaveName == "" {
                    if let credential:NSURLCredential = EWWave.getStoredCredential() {
                        APP_DELEGATE.currentWaveName = credential.user!
                        APP_DELEGATE.currentWaveIndex = 0
                    }
                }
                NSLog("2222222222 currentWaveName: \(APP_DELEGATE.currentWaveName)")
                NSLog("3333333333 wavesPickerSize: \(self.myWaves.count)")
                
                self.wavesPicker = UIPickerView(frame: CGRectZero)
                self.attachPickerToTextField(self.waveSelected, picker: self.wavesPicker)
                
                self.wavesPicker.selectRow(APP_DELEGATE.currentWaveIndex, inComponent: 0, animated: true)
                
                NSLog("setting wave index: \(APP_DELEGATE.currentWaveIndex)")
                self.navigationController?.navigationBar.topItem?.title = "";//[APP_DELEGATE currentWaveName];
                
                self.waveSelected.text = APP_DELEGATE.currentWaveName
                self.refreshView()
            },
            failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
        })
    }
    
    func refreshView() -> Void {
        //        self.startRefresh(self.refreshControl)
    }
    
    
    func attachPickerToTextField(textField:UITextField!, picker:UIPickerView!) -> Void {
        picker.delegate = self
        picker.dataSource = self
        
        textField.delegate = self
        textField.inputView = picker
    }
    
    
    
    func updatePhotosCount() -> Void {
        
        let theDate = APP_DELEGATE.getPhotosCountSinceLast { (count) -> Void in
            NSLog("found \(count) photos")
        }
        
        let dateFormat:NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "MMM dd, yyyy hh:mm a"
        let usLocale:NSLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormat.locale = usLocale

        let theDateTime = dateFormat.stringFromDate(theDate)
        self.sinceDateTime.setTitle(theDateTime, forState: .Normal)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLog("!!!!!!!!!!!!!!!!!!!!!!!!! viewWillApear")
        
        self.updatePhotosCount()
        
        //    [[self sinceDateTime] performSelectorOnMainThread:@selector(setText:) withObject:theDateTime waitUntilDone:NO];
        self.reloadWavesPicker()
        
        
        let navController = self.parentViewController as NavigationTabBarViewController
        APP_DELEGATE.getPhotosCountSinceLast({ (count) -> Void in
            navController.waveAllButton.setTitle("Wave \(count)", forState: .Normal)
            if count > 0 {
                navController.waveAllButton.hidden = false
            } else {
                navController.waveAllButton.hidden = true
            }
        })

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func pictureSaved() -> Void {
        //    [self checkForNewImages];
//        APP_DELEGATE.checkForInitialViewToPresent()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.myWaves.count
    }
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let label:UILabel = UILabel()
        label.backgroundColor = UIColor.orangeColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue", size:14)
        label.textAlignment = .Center
        //WithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 60)];
        label.text = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        return label;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.waveSelected.text = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        self.waveSelected.resignFirstResponder()
        
        NSLog(",,,,,,,,,,,,,,,,,,, did select row: \(row)")
        APP_DELEGATE.currentWaveName = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        APP_DELEGATE.currentWaveIndex = row
        //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
        
        self.navigationController?.navigationBar.topItem?.title = "";//[APP_DELEGATE currentWaveName];
        self.refreshView()
    }
    
    
    func numberOfRowsInPickerView(pickerView:UIPickerView) -> Int {
        return self.myWaves.count
    }
    
}