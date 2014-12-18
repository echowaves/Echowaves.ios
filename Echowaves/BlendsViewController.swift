//
//  BlendsViewController.swift
//  Echowaves
//
//  Created by D on 12/7/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class BlendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var waveSelected:UITextField!
    @IBOutlet var wavesPicker:UIPickerView!
    var myWaves = []
    var blendedWith = []
    
    
    @IBAction func unblendBlendedButtonClicked(sender: AnyObject){
        let button:UIView = sender as UIView
        var waveName:String = ""
        
        for var parent:UIView! = button.superview; parent != nil; parent = parent.superview {
            if parent.isKindOfClass(UITableViewCell) == true {
                let cell:UITableViewCell = parent as UITableViewCell
                let path = self.tableView.indexPathForCell(cell)
                waveName = ((self.blendedWith[path!.row] as NSDictionary).objectForKey("name") as String)
                
                EWBlend.showAlertWithMessageAndCancelButton("Unblend?",
                    okAction: { (UIAlertAction) -> Void in
                        EWBlend.unblendFrom(waveName,
                            currentWave: APP_DELEGATE.currentWaveName,
                            success: { () -> () in
                                self.refreshView()
                            },
                            failure: { (error) -> () in
                                NSLog("error: \(error.debugDescription)")
                        })
                    },
                    fromSender: self)
                break // for
            }
        }
        NSLog("unblending blended wave \(waveName)")
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("--------didDeselectRowAtIndexPath \(indexPath.row) for section \(indexPath.section)");
        
        
        if indexPath.section == 0 {
            let pickAWaveViewController:AcceptBlendingRequestViewController = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("PickAWaveView") as AcceptBlendingRequestViewController
            pickAWaveViewController.origToWave = APP_DELEGATE.currentWaveName
            pickAWaveViewController.toWave = APP_DELEGATE.currentWaveName
            pickAWaveViewController.fromWave = ((self.blendedWith[indexPath.row] as NSDictionary).objectForKey("name") as String)
            
            self.navigationController?.pushViewController(pickAWaveViewController, animated: true)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    self.wavesPicker.style = HPStyle_iOS7;
        //    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];
        
        self.refreshView()
    }
    
    func refreshView() -> Void {
        EWBlend.getBlendedWith(
            { (waveNames) -> () in
                self.blendedWith = waveNames;
                self.tableView.reloadData()
                self.tableView.reloadInputViews()
            },
            failure: { (error) -> () in
                NSLog("error \(error.description)")
        })
    }
    
    
    func reloadWavesPicker() -> Void {
        EWWave.getAllMyWaves({ (waves) -> () in
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
            self.navigationController?.navigationBar.topItem?.title = ""
            
            self.waveSelected.text = APP_DELEGATE.currentWaveName
            self.refreshView()
            },
            failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
        })
        
    }
    
    func attachPickerToTextField(textField:UITextField!, picker:UIPickerView!) -> Void {
        picker.delegate = self
        picker.dataSource = self
        
        textField.delegate = self
        textField.inputView = picker
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("(((((((((((((((((((((viewWillAppear")
        self.reloadWavesPicker()
        
        
        let navController = self.parentViewController as NavigationTabBarViewController
        APP_DELEGATE.getPhotosCountSinceLast({ (count) -> Void in
            navController.waveAllButton.setTitle("Wave: \(count)", forState: .Normal)
            if count > 0 {
                navController.waveAllButton.hidden = false
            } else {
                navController.waveAllButton.hidden = true
            }
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        NSLog("---------------numberOfSectionsInTableView")
        return 1
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        NSLog("---------------titleForHeaderInSection \(section)")
        
        if section == 0 {
            return "\(APP_DELEGATE.currentWaveName) blends with: \(self.blendedWith.count)"
        }
        return "0"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("---------------numberOfRowsInSection \(section)")
        
        if section == 0 {
            NSLog("\(self.blendedWith.count)")
            return self.blendedWith.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("--------cellForRowAtIndexPath \(indexPath.row) for section \(indexPath.section)")
        var cell:UITableViewCell?
        var cellIdentifier:NSString?
        if indexPath.section == 0 {
            cellIdentifier = "BlendedWith"
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!) as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let waveLabel = cell?.viewWithTag(100) as UILabel
        
        NSLog("wave label: \(waveLabel.text)")
        
        if indexPath.section == 0 {
            waveLabel.text = ((self.blendedWith[indexPath.row] as NSDictionary).objectForKey("name") as String)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.clipsToBounds = true
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height:CGFloat  = 44
        return height
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //    NSLog(@"5555555555555 numberOfRowsInComponent: %lu", (unsigned long)self.myWaves.count);
        return self.myWaves.count
    }

    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let label:UILabel = UILabel()
    label.backgroundColor = UIColor.orangeColor()
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "HelveticaNeue", size: 14)
    label.textAlignment = NSTextAlignment.Center
    //WithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 60)];
    
    let waveName = ((self.myWaves[row] as NSDictionary).objectForKey("name") as String)
    
    label.text = waveName
    return label
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.waveSelected.text =  ((self.myWaves[row] as NSDictionary).objectForKey("name") as String)
    self.waveSelected.resignFirstResponder()
    
    NSLog(",,,,,,,,,,,,,,,,,,, did select row: \(row)")
    APP_DELEGATE.currentWaveName = self.waveSelected.text
    APP_DELEGATE.currentWaveIndex = row
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    self.navigationController?.navigationBar.topItem?.title = ""//[APP_DELEGATE currentWaveName];
    self.refreshView()
    }

    
//    
//    - (NSInteger)numberOfRowsInPickerView:pickerView
//    {
//    return [self myWaves].count;
//    }

    
    
}
