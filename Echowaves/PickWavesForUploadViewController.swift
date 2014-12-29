//
//  PickWavesForUploadViewController.swift
//  Echowaves
//
//  Created by D on 12/9/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class  PickWavesForUploadViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var myWavesTableView:UITableView!
    var myWaves = []
    
    @IBOutlet weak var waveNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        EWWave.getAllMyWaves(
            { (waves) -> () in
                self.myWaves = waves
                self.myWavesTableView.reloadData()
                self.myWavesTableView.reloadInputViews()
            },
            failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
        })
        APP_DELEGATE.getPhotosCountSinceLast { (count) -> Void in
            self.waveNowButton.setTitle("Wave \(count) Now", forState: .Normal)
        }
        
    }
    
    @IBAction func waveOnClicked(sender:AnyObject!) {
        let waveOn:UISwitch = sender as UISwitch
        
        var cell:UITableViewCell = waveOn.superview?.superview as UITableViewCell
        let label = cell.contentView.viewWithTag(500) as UILabel
        let waveName = label.text
        
        EWWave.showLoadingIndicator(self)
        EWWave.makeWaveActive(waveName!,
            active: waveOn.on,
            success: { (waveName) -> () in
                EWWave.hideLoadingIndicator(self)
            }, failure: { (errorMessage) -> () in
                EWWave.hideLoadingIndicator(self)
                EWWave.showAlertWithMessage(errorMessage, fromSender: self)
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "wavesPickerCell"
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        let label:UILabel = cell?.contentView.viewWithTag(500) as UILabel
        let waveOn:UISwitch = cell?.contentView.viewWithTag(501) as UISwitch
        label.text = ((self.myWaves[indexPath.row] as NSDictionary).objectForKey("name") as String)
        let isActive:Int = ((self.myWaves[indexPath.row] as NSDictionary).objectForKey("active") as Int)
        if (isActive == 1) {
            waveOn.on = true
        } else {
            waveOn.on = false
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myWaves.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}
