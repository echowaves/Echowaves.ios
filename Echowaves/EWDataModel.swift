//
//  EWDataModel.swift
//  Echowaves
//
//  Created by D on 11/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

let EWHost = "http://echowaves.com"
let APP_DELEGATE = UIApplication.sharedApplication().delegate as EchowavesAppDelegate
let EWAWSBucket = "http://images.echowaves.com"
let USER_DEFAULTS = NSUserDefaults.standardUserDefaults()

var loadingIndicator: UIAlertController?;
var alertShowing: Bool = false;


@objc class EWDataModel : NSObject {
    
    
    class func showLoadingIndicator(sender: AnyObject) -> () {
        if (loadingIndicator == nil) {
            loadingIndicator! = UIAlertController(title: "Loading...", message: "Please Wait", preferredStyle: UIAlertControllerStyle.Alert)
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        (sender as UIViewController).presentViewController(loadingIndicator!, animated: true, completion: nil)
        alertShowing = true;
    }
    
    
    class func hideLoadingIndicator(sender: AnyObject) -> () {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        if (loadingIndicator != nil) {
            loadingIndicator!.removeFromParentViewController()
        }
        loadingIndicator = nil;
        alertShowing = false;
    }
    
    class func isLoadingIndicatorShowing() ->(Bool) {
        return alertShowing;
    }
 
    
    class func showAlertWithMessage(message: String, fromSender: AnyObject) -> () {
        var alertMessage = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alertMessage. tag = 10002
        alertMessage.delete(fromSender)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
        alertMessage.addAction(ok)
        (fromSender as UIViewController).presentViewController(alertMessage, animated: true, completion: nil)
    }

    class func showAlertWithMessageAndCancelButton(message: String,  fromSender: AnyObject) -> () {
        let alertMessage = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alertMessage.tag = 10003
        alertMessage.delete(fromSender)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        alertMessage.addAction(ok)
        alertMessage.addAction(cancel)
        (fromSender as UIViewController).presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    class func showErrorAlertWithMessage(message: String, fromSender: AnyObject) -> () {
        let errorMessage = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        errorMessage.tag = 10001
        errorMessage.delete(fromSender)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        errorMessage.addAction(cancel)
        (fromSender as UIViewController).presentViewController(errorMessage, animated: true, completion: nil)
    }

    
}
