//
//  DateTimePickerViewController.swift
//  Echowaves
//
//  Created by D on 12/9/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation


class DateTimePickerViewController : UIViewController {
    @IBOutlet var datePicker:UIDatePicker!
    @IBOutlet var timePicker:UIDatePicker!
    @IBOutlet var photosCount:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //    [self dateTimePicker].datePickerMode = UIDatePickerModeDateAndTime;
        
        let dateTime = USER_DEFAULTS.objectForKey("lastCheckTime") as NSDate?
        self.datePicker.date = dateTime!
        self.timePicker.date = dateTime!
        
        EWImage.checkForNewAssetsToPostToWaveSinceDate(self.dateFromPickers(),
            success: { (assets) -> () in
                self.photosCount.text =  "\(assets.count)"
            }, failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
                NSLog("Error updating photos count")
        })
    }
    
    
    @IBAction func resetToNow(sender: AnyObject?) {
        var dateTime = NSDate()
        self.datePicker.date = dateTime
        self.timePicker.date = dateTime
        
        EWImage.checkForNewAssetsToPostToWaveSinceDate(self.dateFromPickers(),
            success: { (assets) -> () in
                self.photosCount.text =  "\(assets.count)"
            }, failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
                NSLog("Error updating photos count")
        })
    }
    
    
    @IBAction func dateChanged(sender:AnyObject!) {
        NSLog("((((((((((((((((((((((( date changed")
        EWImage.checkForNewAssetsToPostToWaveSinceDate(self.dateFromPickers(),
            success: { (assets) -> () in
                self.photosCount.text =  "\(assets.count)"
            }, failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
                NSLog("Error updating photos count")
        })
    }
    
    
    @IBAction func timeChanged(sender: AnyObject!) {
        NSLog("))))))))))))))))))))))) time changed")
        EWImage.checkForNewAssetsToPostToWaveSinceDate(self.dateFromPickers(),
            success: { (assets) -> () in
                self.photosCount.text = "\(assets.count)"
            }, failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
                NSLog("Error updating photos count")
        })
    }
    
    @IBAction func setDateTime(sender: AnyObject!) {
        
        let date = self.dateFromPickers()
        NSLog("aha date \(date)")
        USER_DEFAULTS.setObject(date, forKey: "lastCheckTime")
        USER_DEFAULTS.synchronize()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    func dateFromPickers() -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringFromDate = dateFormatter.stringFromDate(self.datePicker.date)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let stringFromTime = timeFormatter.stringFromDate(self.timePicker.date)
        
        
        let dateTimeString = "\(stringFromDate) \(stringFromTime)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return formatter.dateFromString(dateTimeString)!
    }
    
    
}