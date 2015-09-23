//
//  SignupViewController.swift
//  CEInema
//
//  Created by shaowei on 8/12/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
/// Sign up page controller
///
/// Help user register for the newsletter
class SignupViewController: UIViewController, UITextFieldDelegate {
    /// user name text field outlet
    @IBOutlet weak var SignupName: UITextField! { didSet { SignupName.delegate = self } }
    /// user email address field outlet
    @IBOutlet weak var SignupEmail: UITextField! { didSet { SignupEmail.delegate = self } }
    /// Confirm button touched, call confirm()
    @IBAction func ConfirmButton(sender: AnyObject) {
        confirm()
    }
    /// Cancel button touched, return to Home view
    @IBAction func CancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ///add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = Mirror(reflecting: self).description.stringByReplacingOccurrencesOfString("Mirror for ", withString: "")
            print("Screen name: \(screenName)")
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    /// Show notifications with message string
    ///
    /// - parameter msg: message string that needs to be demontrated
    /// - returns: none
    private func showMsg(msg:String) {
        let alert = UIAlertView(title: "Notice", message: msg, delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }
    
    /// Triggered once the user confirm the submission.
    /// Checks the validation of inputed email address.
    /// If the address is correct, then make a http request to save the registration info
    ///
    /// - parameter nothing:
    /// - returns: nothing
    private func confirm() {
        
        if SignupEmail.text!.isEmpty {
            showMsg("Please sign up with your email address, thanks.")
            return
        }
        if !isValidEmail(SignupEmail.text!) {
            showMsg("Please make sure your email address is correct, thanks.")
            return
        }
        var name = SignupName.text!
        var email = SignupEmail.text!
        //save email to web sever
        name = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        email = email.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        //name = name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        //email = email.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let idString = NSString(format: "http://ceitraining.org/web_services/media.cfc?method=saveSubscriber&name=%@&email=%@", name, email) as String
        let url = NSURL(string: idString)
        print("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 210)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 210)
    }
    /// Change view position when keyboard shows up
    ///
    /// - parameter up: indicate the direction of keyboard 
    /// - parameter moveValue: indicate the amount of distance need to move
    /// - returns: none
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    /// Validate the email address
    ///
    /// - parameter String: input email address
    /// - returns: Bool indicate if the addresss is valid or not
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}
