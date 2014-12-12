//
//  EWBlend.swift
//  Echowaves
//
//  Created by D on 11/2/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class EWBlend: EWDataModel {
    
    
    class func unblendFrom(
        waveName:String,
        currentWave: String,
        success:() -> (),
        failure:(error: NSError!) -> ()) -> () {
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            
            let parameters = ["wave_name": waveName, "from_wave": currentWave]
            
            manager.POST("\(EWHost)/unblend.json", parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success();
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
            
    }
    
    
    class func getBlendedWith(
        success:(waveNames:NSArray) -> (),
        failure:(error: NSError!) -> ()) -> () {
            
            let manager = AFHTTPRequestOperationManager()
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters = ["wave_name":APP_DELEGATE.currentWaveName]
            
            
            manager.GET("\(EWHost)/blended-with.json",
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success(waveNames: responseObject as NSArray)
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
    }
    
    
    class func acceptBlending(
        origMyWaveName: String,
        myWaveName: String,
        friendWaveName:String,
        success:() -> (),
        failure:(error: NSError!) -> ()) -> () {
            
            let manager = AFHTTPRequestOperationManager()
            
            // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
            
            //ideally not going to need the following line, if making a request to json service
            manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
            
            let parameters =
            ["orig_my_wave_name": origMyWaveName,
                "my_wave_name": myWaveName,
                "friend_wave_name": friendWaveName]
            
            manager.POST("\(EWHost)/accept_blending.json",
                parameters:parameters,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    success();
                },
                failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                    println("Error: \(error.localizedDescription)")
                    failure(error: error)
            })
    }
}
