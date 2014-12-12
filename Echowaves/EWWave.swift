//
//  EWWave.swift
//  Echowaves
//
//  Created by D on 11/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class EWWave : EWDataModel {
    //    var waveName: String
    
    //
    class func echowavesProtectionSpace() -> (NSURLProtectionSpace) {
        let url:NSURL = NSURL(string: EWHost)!

        
        let protSpace =
        NSURLProtectionSpace(
            host: url.host!,
            port: 80,
            `protocol`: url.scheme?,
            realm: nil,
            authenticationMethod: nil)
        
        println("prot space: \(protSpace)")
        return protSpace
    }

    class func storeCredential(waveName: String, wavePassword:String)  -> () {
        let protSpace = EWWave.echowavesProtectionSpace()
        
        if let credentials: NSDictionary = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(protSpace) {
            
            //remove all credentials
            for credentialKey in credentials {
                let credential = (credentials.objectForKey(credentialKey.key) as NSURLCredential)
                NSURLCredentialStorage.sharedCredentialStorage().removeCredential(credential, forProtectionSpace: protSpace)
            }
        }
            //store new credential
            let credential = NSURLCredential(user: waveName, password: wavePassword, persistence: NSURLCredentialPersistence.Permanent)
            NSURLCredentialStorage.sharedCredentialStorage().setCredential(credential, forProtectionSpace: protSpace)
        
    }
    
    
    class func getStoredCredential() -> (NSURLCredential?)  {
        //check if credentials are already stored, then show it in the tune in fields
        
        if let credentials: NSDictionary? = NSURLCredentialStorage.sharedCredentialStorage().credentialsForProtectionSpace(EWWave.echowavesProtectionSpace()) {
            return credentials?.objectEnumerator().nextObject() as NSURLCredential?
        }
        return nil
    }
    
    
    
    class func createWave(
        waveName: String,
        wavePassword: String,
        confirmPassword: String,
        success:(waveName:String) ->(),
        failure:(errorMessage: String) -> ())
    {
        //wipe out cookies first
        let  cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
        let cookies: NSArray = cookieStorage.cookiesForURL(NSURL(fileURLWithPath: EWHost)!)!
        
        for cookie in cookies  {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie as NSHTTPCookie);
        }
        
        
        let manager = AFHTTPRequestOperationManager()
        
        // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
        
        //ideally not going to need the following line, if making a request to json service
        manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        
        let parameters = ["name": waveName,
            "pass": wavePassword,
            "pass1": confirmPassword]
        
        manager.POST("\(EWHost)/register.json",
            parameters:parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("+++wave created")
                println("wave name \(waveName)")
                
                EWWave.storeCredential(waveName, wavePassword: wavePassword)
                success(waveName: waveName)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: \(error.localizedDescription)")
                let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                failure(errorMessage: "Unable to createWave: \(errorMessage)")
        })
        
    }
    
    
    class func createChildWave(newWaveName: String,
        success:(newWaveName: String) -> Void,
        failure:(errorMessage:String) -> Void) -> Void
    {
        let manager = AFHTTPRequestOperationManager()
        
        // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
        
        //ideally not going to need the following line, if making a request to json service
        manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        
        let parameters = ["name": newWaveName];
        
        manager.POST(
            "\(EWHost)/create-child-wave.json",
            parameters:parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("+++child wave created")
                println("wave name \(newWaveName)")
                
                success(newWaveName: newWaveName)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: \(error.localizedDescription)")
                let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                failure(errorMessage: "Unable to create child Wave: \(errorMessage)")
        })
    }
    
    
    class func makeWaveActive(waveName: String,
        active: Bool,
        success:(waveName: String) -> (),
        failure:(errorMessage:String) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["wave_name": waveName,
                "active": active]
            
            manager.POST("\(EWHost)/make-wave-active.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveName: waveName)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                    failure(errorMessage: "Unable to make wave \(waveName) active(\(active)): \(errorMessage)")
            })
    }
    
    
    class func deleteChildWave(waveName: String,
        success:(waveName: String) -> (),
        failure:(errorMessage:String) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["wave_name": waveName]
            
            manager.POST("\(EWHost)/delete-child-wave.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveName: waveName)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                    failure(errorMessage: "Unable to delete child wave \(waveName): \(errorMessage)")
            })
    }
    
    
    class func getWaveDetails(waveName: String,
        success:(waveDetails:NSDictionary) -> (),
        failure:(errorMessage: String) ->()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["wave_name": waveName]
            
            manager.GET("\(EWHost)/wave-details.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveDetails: responseObject as NSDictionary)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                    failure(errorMessage: "Unable to getWaveDetails \(waveName): \(errorMessage)")
            })
    }
    
    
    
    class func getAllMyWaves(
        success:(waves: NSArray) -> (),
        failure:(error: NSError) -> ()) -> () {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
            
            let manager = AFHTTPRequestOperationManager()
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = []
            manager.GET("\(EWHost)/all-my-waves.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    success(waves: responseObject as NSArray)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    failure(error: error)
            })
            
    }
    
    
    //
    //
    class func storeIosToken(waveName: String,
        token: String,
        success:(waveName: String) -> (),
        failure:(errorMessage:String) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["name": waveName,
                "token": token]
            
            manager.POST("\(EWHost)/register-ios-token.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveName: waveName)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                    failure(errorMessage: "Unable to store token for wave: \(waveName): \(errorMessage)")
            })
    }
    
    
    class func sendPushNotifyBadge(numberOfImages: Int,
        success:() -> (),
        failure:(error: NSError) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["badge": "\(numberOfImages)"]
            
            manager.POST("\(EWHost)/push-notify.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    println("+++notification pushed")
                    success()
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error)")
                    failure(error: error)
            })
            
    }
    
    
    class func tuneIn(waveName: String,
        wavePassword: String,
        success:(waveName: String) -> (),
        failure:(errorMessage:String) -> ()) -> () {
            //wipe out cookies first
            //wipe out cookies first
            let  cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
            let cookies: NSArray = cookieStorage.cookiesForURL(NSURL(fileURLWithPath: EWHost)!)!
            
            for cookie  in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie as NSHTTPCookie)
            }
            
            
            let manager = AFHTTPRequestOperationManager()
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["name": waveName,
                "pass": wavePassword]
            
            manager.POST("\(EWHost)/login.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    EWWave.storeCredential(waveName, wavePassword: wavePassword)
                    success(waveName: waveName)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    let errorMessage: AnyObject? = operation.responseObject.objectForKey("error")
                    failure(errorMessage: "Unable to tuniInto wave \(waveName): \(errorMessage)")
            })
    }
    
    class func tuneOut() -> () {
        let manager = AFHTTPRequestOperationManager()
        
        //ideally not going to need the following line, if making a request to json service
        manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        
        APP_DELEGATE.currentWaveName = ""
        manager.POST("\(EWHost)/logout.json",
            parameters:nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("+++TunedOut")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("+++Error tuninOut")
        })
        
        
    }
    
    
}