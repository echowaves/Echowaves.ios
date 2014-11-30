//
//  DetailedImageViewController.swift
//  Echowaves
//
//  Created by D on 11/20/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import AddressBookUI
import MessageUI


class DetailedImageViewController : UIViewController,
UIAlertViewDelegate,
ABPeoplePickerNavigationControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIScrollViewDelegate {
    
    var imageIndex:UInt = 0
    var fullSizeImageLoaded = false
    var waveName = ""
    var imageName = ""
    var navItem:UINavigationItem? = UINavigationItem()
//    var navBar:UINavigationBar=UINavigationBar()

    @IBOutlet var progressView:UIProgressView!
    @IBOutlet var highQualityButton:UIButton!
    @IBOutlet var imageScrollView:UIScrollView!
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var waveNameLable:UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageScrollView.delegate = self;
        self.imageScrollView.minimumZoomScale = 1.0
        self.imageScrollView.maximumZoomScale = 100.0
        self.progressView.progress = 0.0
        self.progressView.hidden = true
        
        self.initView()
        
        let tapOnce = UITapGestureRecognizer(target: self, action: Selector("tapOnce:"))
        
        let tapTwice = UITapGestureRecognizer(target: self, action: "tapTwice:")
        
        tapOnce.numberOfTapsRequired = 1
        tapTwice.numberOfTapsRequired = 2
        
        //stops tapOnce from overriding tapTwice
        tapOnce.requireGestureRecognizerToFail(tapTwice)
        
        // then need to add the gesture recogniser to a view
        // - this will be the view that recognises the gesture
        self.view.addGestureRecognizer(tapOnce)
        self.view.addGestureRecognizer(tapTwice)
    }
    
    @IBAction func loadFullImage(sender: AnyObject?) {
        self.progressView.hidden = false
        self.fullSizeImageLoaded = true
        self.highQualityButton.hidden = true
        
        EWImage.loadFullImage(self.imageName,
            waveName: self.waveName,
            success: { (image) -> Void in
                self.imageView.image = image
                self.progressView.hidden = true
            },
            failure: { (error) -> Void in
                self.progressView.hidden = true
                EWDataModel.showErrorAlertWithMessage("Error Loading full image", fromSender: self)
                NSLog("error: \(error.description)")
                self.fullSizeImageLoaded=false
            },
            progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                self.progressView.progress = (Float(totalBytesRead)/Float(totalBytesExpectedToRead))
        })
    }
    
    
    func tapOnce(gesture: UIGestureRecognizer) -> () {
        if((self.navigationController?.navigationBarHidden) != nil) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.waveNameLable.hidden = false
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated:true)
            self.waveNameLable.hidden = true
        }
    }
    
    func tapTwice(gesture: UIGestureRecognizer) -> () {
        let point = gesture.locationInView(imageView)
        let rectToZoomOutTo = CGRectMake(point.x/2, point.y/2, self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
        self.imageScrollView.zoomToRect(rectToZoomOutTo, animated: true)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateView()
    }
    
    
    func initView() -> () {
        NSLog(",,,,,,,,,,,,,,,,,,,,,,,\(waveName)/\(imageName)")
        EWImage.loadThumbImage(imageName,
            waveName: waveName,
            success: { (image) -> () in
                self.imageView.image = image
                self.imageScrollView.contentSize = image.size
            },
            failure: { (error) -> () in
                EWDataModel.showErrorAlertWithMessage("Error Loading thumb image", fromSender: self)
                NSLog("error: \(error.description)")
            }, progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> () in
                NSLog("progress...")
        })
        
        
    }
    
    func updateView() -> () {
        if((self.navigationController?.navigationBarHidden) != nil) {
            self.waveNameLable.hidden = true
        } else {
            self.waveNameLable.hidden = false
        }
        
        
        self.navItem?.rightBarButtonItems = nil
        
        self.waveNameLable.text = self.waveName
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSSS"
        let dateString = self.imageName.substringWithRange(Range(start:advance(self.imageName.startIndex,0), end: advance(self.imageName.startIndex,18)))
        
        NSLog("imageName  = \(imageName)")
        NSLog("dateString = \(dateString)")
        let dateTime = formatter.dateFromString(dateString)
        
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        self.navItem?.title = formatter.stringFromDate(dateTime!)
        
        //        [[self navigationItem].backBarButtonItem setTitle:@" qwe"];
        
        if (self.waveName == APP_DELEGATE.currentWaveName) {
            
            let deleteButton  = UIBarButtonItem(barButtonSystemItem: .Trash,
                target: self,
                action: "deleteImage")
            
            let shareButton = UIBarButtonItem(barButtonSystemItem: .Action,
                target: self,
                action: "shareImage")
            
            self.navItem?.rightBarButtonItems = [shareButton, deleteButton]
        } else {
         
            self.navItem?.rightBarButtonItems =
                [UIBarButtonItem(
                    barButtonSystemItem: .Save,
                    target: self,
                    action: "saveImage")]
        }
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    func deleteImage() -> Void {
        NSLog("deleting image")
        
        EWImage.showAlertWithMessageAndCancelButton("Delete image?",
            okAction: { (UIAlertAction) -> Void in
                EWImage.showLoadingIndicator(self)
                EWImage.deleteImage(self.imageName,
                    waveName: self.waveName,
                    success: { () -> () in
                        EWImage.hideLoadingIndicator(self)
                        self.navigationController?.popViewControllerAnimated(true)
                    },
                    failure: { (error) -> () in
                        EWImage.hideLoadingIndicator(self)
                        EWImage.showErrorAlertWithMessage("Unable to delete image", fromSender: self)
                })
            },
            fromSender: self)
    }
    
    
    func shareImage() -> Void {
        NSLog("sharing image")
        
        var errorRef: Unmanaged<CFErrorRef>? = nil
        let addressBookRef:ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &errorRef)?.takeRetainedValue()

        if let addressBook: ABAddressBookRef  = addressBookRef {
            ABAddressBookRequestAccessWithCompletion(addressBook) {
                (accessGranted, permissionError) in
                if(accessGranted) {

                    let peoplePicker = ABPeoplePickerNavigationController()
                    peoplePicker.peoplePickerDelegate = self
                    
                    self.presentViewController(peoplePicker,
                        animated: true, completion: { () -> Void in
                            NSLog("done presenting")
                    })
                    
                } else {
            EWImage.showAlertWithMessage("Enable access to contacts for Echowaves in preferences", fromSender:self)
                }
            }

        } else {
            let e = errorRef!.takeUnretainedValue() as AnyObject as NSError
            println("An error occured: \(e)")
                        EWImage.showAlertWithMessage("Error accessing address book", fromSender:self)
        }
        
                    
        
    }
    
    
    func saveImage() -> Void {
        EWImage.saveImageToAssetLibrary(self.imageView.image!,
            success: { () -> () in
                EWDataModel.showAlertWithMessage("Photo Saved to iPhone", fromSender: self)
            }, failure: { (error) -> () in
                EWDataModel.showErrorAlertWithMessage("Error saving", fromSender: self)
        })
        
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        let multiValue: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        let phone = ABMultiValueCopyValueAtIndex(multiValue, index).takeRetainedValue() as String
        
        println("selected = \(phone)")

                                    let smscontroller = MFMessageComposeViewController()
                                    if MFMessageComposeViewController.canSendText() == true {
                                        EWImage.shareImage(self.imageName,
                                            waveName: self.waveName,
                                            success: { (token) -> () in
                                                smscontroller.recipients = [phone]
                                                smscontroller.messageComposeDelegate = self;
        
                                                smscontroller.body = "Look at my photo and blend with my wave http://echowaves.com/mobile?token=\(token)"
        
                                                self.presentViewController(smscontroller,
                                                    animated: true,
                                                    completion: { () -> Void in
                                                        NSLog("sms controller presented")
                                                })
                                            },
                                            failure: { (error) -> () in
                                                EWDataModel.showAlertWithMessage(error.description, fromSender: self)
                                        })
                                    }//if can send text
    }
    
    
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            NSLog("dismissing people picker")
        })
    }
    
    
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch result.value {
        case MessageComposeResultCancelled.value:
            NSLog("Cancelled")
        case MessageComposeResultFailed.value:
            EWImage.showAlertWithMessage("Failed SMS", fromSender:self)
        case MessageComposeResultSent.value:
            NSLog("MessageComposeResultSent")
        default:
            NSLog("default case")
        }
        self.dismissViewControllerAnimated(true,
            completion: { () -> Void in
                NSLog("dismissed sms controller")
        })
        
    }
    
    
}
