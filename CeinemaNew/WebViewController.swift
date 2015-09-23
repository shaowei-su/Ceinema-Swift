//
//  WebViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/4/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import WebKit
/// Web view controller to load CEI homepage
///
class WebViewController: UIViewController {

    /// UI Web View outlet
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = Mirror(reflecting: self).description.stringByReplacingOccurrencesOfString("Mirror for ", withString: "")
            //print("Screen name: \(screenName)")
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: "http://m.ceitraining.org")
        let requestObj = NSURLRequest(URL: url!)
        self.webView.loadRequest(requestObj)
        // Do any additional setup after loading the view.
    }
}
