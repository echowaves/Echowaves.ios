    //
//  EWImage.swift
//  Echowaves
//
//  Created by D on 11/3/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import AssetsLibrary

class EWImage : EWDataModel {
    
    class func checkForNewAssetsToPostToWaveSinceDate(date: NSDate,
        success:(assets: NSArray) -> (),
        failure:(error: NSError) -> ()) -> () {
            var assets: NSMutableArray = NSMutableArray()
            
            println("----------------- Checking images")
            //find if there are any new images to post
            //http://iphonedevsdk.com/forum/iphone-sdk-development/94700-directly-access-latest-photo-from-saved-photos-camera-roll.html
            var library = ALAssetsLibrary()
            
            
            
            // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
            library.enumerateGroupsWithTypes(
                ALAssetsGroupSavedPhotos,
                usingBlock: { (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                     if group != nil {
                    // Within the group enumeration block, filter to enumerate just videos.
                    group!.setAssetsFilter(ALAssetsFilter.allPhotos())
                    
                    // iterating over all assets
                    group!.enumerateAssetsUsingBlock({ (alAsset: ALAsset!, index: Int, innerStop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        // The end of the enumeration is signaled by asset == nil.
                        if alAsset != nil
                        {
                            let currentAssetDateTime = alAsset.valueForProperty(ALAssetPropertyDate) as NSDate
                            
                            if USER_DEFAULTS.objectForKey("lastCheckTime") == nil {
                                USER_DEFAULTS.setObject(date, forKey: "lastCheckTime")
                                USER_DEFAULTS.synchronize()
                            }
                            
                            let timeSinceLastPost =
                            currentAssetDateTime.timeIntervalSinceDate(date) // diff
                            
                            if timeSinceLastPost > 0.0 {//this means, found an image that was not posted
                                //first lets add the image to a collection, we will process this collection later.
                                
                                //                    NSLog(@"found image that was posted %f seconds since last check", timeSinceLastPost);
                                
                                assets.addObject(alAsset)
                                
                            } // if timeSinceLastPost
                            
                        } else { // here is at the end of the iterating over assets
                            //                [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
                            //                [USER_DEFAULTS synchronize];
                            success(assets: assets)
                        }
                        
                    })
                     } else if group == nil {
                        println("group is nil")
                    }
                    
                    
                }, failureBlock: {
                    (error: NSError!) in
                    println("Error2!")
            })
    }
    
    
    
    class func operationFromAsset(asset: ALAsset,
        waveName: String,
        success:(operation:AFHTTPRequestOperation, image: UIImage , currentAssetDateTime:NSDate) -> Void ) -> Void {
            
            println("----------------- Posting asset")
            
            let currentAssetDateTime: NSDate = asset.valueForProperty(ALAssetPropertyDate) as NSDate
            let representation: ALAssetRepresentation = asset.defaultRepresentation()
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // post image to echowaves.com
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            var orientation = UIImageOrientation.Up
            let orientationValue:Int? = asset.valueForProperty("ALAssetPropertyOrientation") as? Int
            
            if (orientationValue != nil) {
                orientation = UIImageOrientation(rawValue: orientationValue!)!
            }
            
            var orientedImage:UIImage =
            
//            UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue())!
            
//            UIImage(CGImage: <#CGImage!#>, scale: <#CGFloat#>, orientation: <#UIImageOrientation#>)
            
            UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue(), scale:1.0, orientation:orientation)!
            
            
            let newSize: CGSize  = orientedImage.size
            
            //            newSize.height = newSize.height / 1.0
            //            newSize.width = newSize.width / 1.0
            
            UIGraphicsBeginImageContext(newSize) // a CGSize that has the size you want
            orientedImage.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
            
            //image is the original UIImage
            var resizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            
            let parameters = NSMutableDictionary()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmssSSSS"
            
            let webUploadData: NSData = UIImageJPEGRepresentation(resizedImage, 1.0)
            let dateString = formatter.stringFromDate(currentAssetDateTime)
            
            
            var request:NSURLRequest =
            AFHTTPRequestSerializer().multipartFormRequestWithMethod(
                "POST",
                URLString: "\(EWHost)/upload",
                parameters: parameters,
                constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                    formData.appendPartWithFileData(
                        webUploadData,
                        name: "file",
                        fileName: "\(dateString).jpg",
                        mimeType: "image/jpeg")
                },
                error: nil)
            
            let operation:AFHTTPRequestOperation  = AFHTTPRequestOperation(request: request)
            
            success(operation: operation, image: resizedImage, currentAssetDateTime: currentAssetDateTime);
            
    }
    
    
    class func getAllImagesForWave(
        waveName: String,
        success:(waveImages: NSArray) -> (),
        failure:(error: NSError) -> () ) -> () {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
            
            let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["wave_name": waveName]
            
            
            manager.GET(
                "\(EWHost)/wave.json",
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveImages: responseObject as NSArray)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
    }
    
    
    class func loadImageFromUrl(
        url: String,
        success:(image: UIImage) -> (),
        failure:(error: NSError) -> (),
        progress:(bytesRead: UInt, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> ()) -> () {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
            
            let request = NSURLRequest(URL: NSURL(string: url)!)
            
            var imgOperation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
            
            imgOperation.responseSerializer = AFImageResponseSerializer() as AFImageResponseSerializer
            imgOperation.setCompletionBlockWithSuccess(
                
                { (operation, responseObject) -> Void in
                    success(image: responseObject as UIImage)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                },
                
                failure: { (operation, error) -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    failure(error: error)
            })
            
            
            //            if progress  {
            imgOperation.setDownloadProgressBlock({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                progress(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead);
            })
            //            }
            imgOperation.start()
    }
    
    
    class func loadFullImage(
        imageName: String,
        waveName: String,
        success:(image:UIImage) -> Void,
        failure:(error:NSError) -> Void,
        progress:(bytesRead: UInt, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void ) -> Void {
            let imageUrl = "\(EWAWSBucket)/img/\(waveName)/\(imageName)"
            EWImage.loadImageFromUrl(
                imageUrl,
                success: { (image) -> () in
                    success(image: image)
                },
                failure: { (error) -> () in
                    failure(error: error)
                    
                },
                progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> () in
                    progress(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead) })
    }
    
    
    class func loadThumbImage(
        imageName: String,
        waveName: String,
        success:(image:UIImage) -> (),
        failure:(error:NSError) -> (),
        progress:(bytesRead: UInt, totalBytesRead: Int64, totalBytesExpectedToRead:Int64) -> () ) -> () {
            let imageUrl = "\(EWAWSBucket)/img/\(waveName)/thumb_\(imageName)"
            EWImage.loadImageFromUrl(
                imageUrl,
                success: { (image) -> () in
                    success(image: image)
                },
                failure: { (error) -> () in
                    failure(error: error)
                },
                progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> () in
                    progress(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpectedToRead) })
            
    }
    
    
    class func deleteImage(
        imageName: String,
        waveName: String,
        success:() -> (),
        failure:(error:NSError) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters =
            ["image_name": imageName,
                "wave_name": waveName]
            
            manager.POST(
                "\(EWHost)/delete-image.json",
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, id: AnyObject!) -> Void in
                    success()
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("Error: \(error)")
                    let rsp: AnyObject? = operation.responseObject.objectForKey("error")
                    println("Response: \(rsp)")
                    failure(error: error)
            })
            
    }
    
    
    class func saveImageToAssetLibrary(
        image: UIImage,
        success:() ->(),
        failure:(error: NSError) -> () ) ->()
    {
        let img: CGImageRef  = image.CGImage
        
        let library = ALAssetsLibrary()
        
        library.writeImageToSavedPhotosAlbum(
            img,
            orientation: ALAssetOrientation.Up,
            completionBlock: { (assetURL: NSURL!, error: NSError!) -> Void in
                if (error? == nil) {
                    println("saved image completed:\nurl: \(assetURL)")
                    success()
                }
                else {
                    println("saved image failed.\nerror code \(error.code)\n\(error.localizedDescription)")
                    failure(error: error)
                }
        })
    }
    
    
    class func shareImage(
        imageName: String,
        waveName: String,
        success:(token: String) -> (),
        failure:(error: NSError ) ->() ) -> () {
            
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["image_name": imageName,
                "wave_name": waveName]
            
            manager.POST(
                "\(EWHost)/share-image.json",
                parameters: parameters,
                success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                    let response = responseObject as NSDictionary
                    let token =  response.objectForKey("token") as String
                    println(",,,,,,,,,,,,,,,,,,token \(token)")
                    success(token: token)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
    }
    
    class func retreiveImageByToken(
        token: String,
        success:(imageName: String, waveName: String) -> (),
        failure:(error: NSError) -> () ) -> () {
            
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["token": token]
            
            manager.POST(
                "\(EWHost)/image-by-token.json",
                parameters: parameters,
                success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                    let response = responseObject as NSDictionary
                    
                    let imageName =  response.objectForKey("name") as String
                    let waveName =  response.objectForKey("name_2") as String
                    success(imageName: imageName, waveName: waveName)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
    }
    
}