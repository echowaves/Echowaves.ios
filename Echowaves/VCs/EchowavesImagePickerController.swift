//
//  EchowavesImagePickerController.swift
//  Echowaves
//
//  Created by D on 12/1/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation
import UIKit

protocol EchowavesImagePickerControllerProtocol {
    func pictureSaved() -> Void
}


class EchowavesImagePickerController:
    UIViewController,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
{
    
    var delegate:EchowavesImagePickerControllerProtocol?
    
    var imagePickerController:UIImagePickerController!
    
    
    func takePicture(sender : AnyObject?) {
        //adjust waving to on
        //    [APP_DELEGATE.wavingViewController.waving setOn:TRUE];
        //    [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
        //    [appDelegate.wavingViewController appStatus].text = @"Use iPhone cam, then come back to EW...";
        
        //    [USER_DEFAULTS setBool:APP_DELEGATE.wavingViewController.waving.on forKey:@"waving"];
        USER_DEFAULTS.synchronize()
        //if(!mDidFinishWCamera) {
        if !self.showImagePicker(UIImagePickerControllerSourceType.Camera, backfacing: false) {
            self.showImagePicker(UIImagePickerControllerSourceType.PhotoLibrary, backfacing: false)
            //    }
        }
        
    }
    
    
    
    func showImagePicker(sourceType:UIImagePickerControllerSourceType, backfacing:Bool)  -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            //        imagePickerController.wantsFullScreenLayout = YES;
            imagePickerController.edgesForExtendedLayout = UIRectEdge.All
            if backfacing {
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
            self.imagePickerController = imagePickerController;
            
            let appDelegate = UIApplication.sharedApplication().delegate
            
            appDelegate?.window!?.addSubview(imagePickerController.view) //?????
            
            //[self.navigationController pushViewController:imagePickerController animated:NO];
            return true
        }
        return false
    }
    
    @IBAction func photoLibraryAction(sender:AnyObject?) {
        self.showImagePicker(UIImagePickerControllerSourceType.PhotoLibrary, backfacing: false)
    }
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        if error != nil {
            NSLog("image save completed with \(error) / \(contextInfo)" )
        }
        else{
            dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    self.delegate?.pictureSaved()
                    APP_DELEGATE.wavingViewController?.updatePhotosCount()
            })
        }
        
        self.imagePickerController.view.removeFromSuperview()
    }
    
    
    // this get called when an image has been chosen from the library or taken from the camera
    //
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            let image:UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
            
            UIImageWriteToSavedPhotosAlbum(image,
                self,
                "image:didFinishSavingWithError:contextInfo:",
                nil)
            
        }else{
            picker.view.removeFromSuperview()
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        NSLog("camera cancelled");
        picker.view.removeFromSuperview()
    }
    
    
}



