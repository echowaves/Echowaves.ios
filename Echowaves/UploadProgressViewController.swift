//
//  UploadProgressViewController.swift
//  Echowaves
//
//  Created by D on 12/10/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation
import AssetsLibrary

class UploadProgressViewController : UIViewController {
    
    var deactivated = false
    
    @IBOutlet var cancelUpload:UIButton!
    @IBOutlet var uploadProgressBar:UIProgressView!
    @IBOutlet var imagesToUpload:UILabel!
    @IBOutlet var currentlyUploadingImage:UIImageView!
    
    var  currentUploadOperation:AFHTTPRequestOperation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.cleanupCurrentUploadView()
        NSLog("#### WavingViewController viewDidLoad ")
        self.currentlyUploadingImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.uploadProgressBar.progress = 0.0
        
        
        //    UIBarButtonItem *btnPause = [[UIBarButtonItem alloc]
        //                                initWithBarButtonSystemItem:UIBarButtonSystemItemPause
        //                                target:self
        //                                action:@selector(OnClick_btnPause:)];
        self.navigationItem.hidesBackButton = true
        //    self.navigationItem.rightBarButtonItem = btnPause;
        self.navigationItem.titleView = UIView()//we want to disable title -- too much info on the screen
    }
    
    func cleanupCurrentUploadView() -> Void {
        self.currentUploadOperation = nil
        
        self.currentlyUploadingImage.hidden = true
        self.currentlyUploadingImage.image = nil
        //    self.imagesToUpload.hidden = TRUE;
        //    [self imagesToUpload].text = [NSString stringWithFormat:@"%lu", (unsigned long)APP_DELEGATE.networkQueue.operationCount];
        self.uploadProgressBar.progress = 0.0
        self.uploadProgressBar.hidden = true
        self.cancelUpload.hidden = true
    }
    
    @IBAction func cancelingCurrentUploadOperation(sender: AnyObject!) {
        self.currentUploadOperation.cancel()
        self.cleanupCurrentUploadView()
    }
    
    
    @IBAction func OnClick_btnPause(sender: AnyObject!) -> Void {
        self.cancelingCurrentUploadOperation(self)
        self.deactivated = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //    override func viewWillAppear(animated: Bool) {
    //        super.viewWillAppear(true)
    //        //    self.navigationController.title = @"streaming wave";
    //        //    self.navigationItem.hidesBackButton = YES;
    //    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForNewAssets(-1)
    }
    
    //    - (void)didReceiveMemoryWarning
    //    {
    //    [super didReceiveMemoryWarning];
    //    // Dispose of any resources that can be recreated.
    //    }
    
    
    
    
    func comeBack() -> Void {
        NSLog("........comeBack")
        //    APP_DELEGATE.uploadProgressViewController = nil;
        
        //    [self.navigationController popViewControllerAnimated:YES];
        // here need to pop 2 levels out
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as UIViewController, animated: true)
        
        self.deactivated = true
        //    [(UINavigationController *)APP_DELEGATE.window.rootViewController popViewControllerAnimated:YES];
    }
    
    
    func checkForNewAssets(assetsCount: Int) -> Void {
        //try to sign in to see if connection is awailable
        
        if let credential = EWWave.getStoredCredential() {
            if self.deactivated == false {
                NSLog("User \(credential.user) already connected with password.")
                
                
                EWWave.tuneIn(credential.user!,
                    wavePassword: credential.password!,
                    success: { (waveName) -> () in
                        NSLog("successsfully signed in")
                        
                        EWImage.checkForNewAssetsToPostToWaveSinceDate(USER_DEFAULTS.objectForKey("lastCheckTime") as NSDate,
                            success: { (assets) -> () in
                                NSLog("************* images to post \(assets.count)")
                                if assets.count == 0 { // this means nothing is found to be posted
                                    self.comeBack()
                                    
                                    if  assetsCount > 0 {
                                        EWWave.sendPushNotifyBadge(assetsCount,
                                            success: { () -> () in
                                                NSLog("!!!!!!!!!!!!!!!pushed notify successfully \(assetsCount)")
                                            },
                                            failure: { (error) -> () in
                                                NSLog("this error should never happen \(error.description)")
                                        })
                                    }
                                } else {
                                    //                                                             for(ALAsset *asset in assets) {
                                    let asset:ALAsset = assets[0] as ALAsset
                                    EWImage.operationFromAsset(asset,
                                        waveName: waveName,
                                        success: { (operation, image, currentAssetDateTime) -> () in
                                            weak var weakOperation:AFHTTPRequestOperation!  = operation
                                            //                                                                           NSLog(@"1");
                                            weakOperation.setUploadProgressBlock({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                                                if self.currentlyUploadingImage.image == nil { // beginning new upload operation here
                                                    self.cancelUpload.hidden = false
                                                    self.uploadProgressBar.hidden = false
                                                    
                                                    self.currentUploadOperation = weakOperation
                                                    self.currentlyUploadingImage.image = image
                                                    self.currentlyUploadingImage.hidden = false
                                                    self.imagesToUpload.text = "\(assets.count)"
                                                    //                                            [self imagesToUpload].hidden = FALSE;
                                                }
                                                
                                                self.uploadProgressBar.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                                            })
                                            
                                            
                                            weakOperation.setCompletionBlockWithSuccess({ (AFHTTPRequestOperation, AnyObject) -> Void in
                                                self.cleanupCurrentUploadView()
                                                if self.deactivated == false {
                                                    USER_DEFAULTS.setObject(currentAssetDateTime, forKey: "lastCheckTime")
                                                    USER_DEFAULTS.synchronize()
                                                    if assetsCount > 0 {
                                                        self.checkForNewAssets(assetsCount)
                                                    } else {
                                                        self.checkForNewAssets(assets.count)
                                                    }
                                                }
                                                }, failure: { (AFHTTPRequestOperation, NSError) -> Void in
                                                    self.cleanupCurrentUploadView()
                                                    if self.deactivated == false {
                                                        USER_DEFAULTS.setObject(currentAssetDateTime, forKey: "lastCheckTime")
                                                        USER_DEFAULTS.synchronize()
                                                        if assetsCount > 0 {
                                                            self.checkForNewAssets(assetsCount)
                                                        } else {
                                                            self.checkForNewAssets(assets.count)
                                                        }
                                                    }
                                                    NSLog("Failed nsnetwork operation")
                                            })
                                            
                                            APP_DELEGATE.networkQueue.addOperation(weakOperation)
                                            //                                                                           [APP_DELEGATE.networkQueue setSuspended:NO];
                                    })// operationFromAsset
                                } //else
                            },
                            failure: { (errorMessage) -> () in
                                EWWave.showErrorAlertWithMessage(errorMessage.description, fromSender: self)
                                self.comeBack()
                        })
                    },
                    failure: { (errorMessage) -> () in
                        EWWave.showErrorAlertWithMessage(errorMessage, fromSender: self)
                        self.comeBack()
                })
                
                
                NSLog("++++++++++++++++++++++++++++++++++++++++++++++++++ done posting, assetsCount \(assetsCount)")
            }
        } else { // credentials are not set, can't really ever happen, something is really wrong here
            NSLog("this error should never happen credentials are not set, can't really ever happen, something is really wrong here 1")
        }
    }
    
    
    
}