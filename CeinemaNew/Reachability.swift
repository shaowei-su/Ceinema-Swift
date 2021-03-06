//
//  Reachability.swift
//  CEInema
//
//  Created by shaowei on 8/20/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import Foundation
/// Used to check Internet connection
public class Reachability {
    /// Check if the network is connected
    ///
    /// - parameter none:
    /// - returns: status bool value indicate whether the Internet is availble
    class func isConnectedToNetwork() -> Bool { 
        
        var Status:Bool = false
        let url = NSURL(string: "http://ceitraining.org/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        _ = (try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}