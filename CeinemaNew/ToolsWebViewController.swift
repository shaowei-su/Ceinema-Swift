//
//  ToolsWebViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/13/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
/// Simulation tool detail page
///
class ToolsWebViewController: UIViewController {
    /// UI web view outlet

    @IBOutlet weak var toolWebView: UIWebView!
    /// Tool full URL
    var toolUrl: String = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = Mirror(reflecting: self).description.stringByReplacingOccurrencesOfString("Mirror for ", withString: "")
            //print("Screen name: \(screenName)")
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        UIApplication.sharedApplication().keyWindow?.addSubview(loadingNotification)
        loadingNotification.labelText = "Loading"
        loadingNotification.detailsLabelText = "Please wait..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            let url = NSURL(string: self.toolUrl)
            let requestObj = NSURLRequest(URL: url!)
            self.toolWebView.loadRequest(requestObj)
            
            dispatch_async(dispatch_get_main_queue()) {
                loadingNotification.hide(true)
                self.view.reloadInputViews()
            }
        }
        
    }
    
    @IBAction func openSafari(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.toolUrl)!)
    }
    @IBAction func rewindWebView(sender: AnyObject) {
        toolWebView.goBack()
    }
    @IBAction func forwardWebView(sender: AnyObject) {
        toolWebView.goForward()
    }

    @IBAction func stopAndClose(sender: AnyObject) {
        toolWebView.stopLoading()
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func refreshWebView(sender: AnyObject) {
        toolWebView.reload()
    }
}
