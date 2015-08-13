//
//  SignupViewController.swift
//  CEInema
//
//  Created by shaowei on 8/12/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var SignupName: UITextField!
    @IBOutlet weak var SignupEmail: UITextField!

    @IBAction func ConfirmButton(sender: AnyObject) {
        confirm()
    }
    @IBAction func CancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    private func showMsg(msg:String) {
        var alert = UIAlertView(title: "Notice", message: msg, delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }
    
    private func confirm() {
        
        if SignupEmail.text.isEmpty {
            showMsg("Please sign up with your email address, thanks.")
            return
        }
        var name = SignupName.text
        var email = SignupEmail.text
        //save email to web sever
        name = name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        email = email.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let idString = NSString(format: "http://ceitraining.org/web_services/media.cfc?method=saveSubscriber&name=%@&email=%@", name, email) as String
        let url = NSURL(string: idString)
        println("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
