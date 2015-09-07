//
//  SignupViewController.swift
//  CEInema
//
//  Created by shaowei on 8/12/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var SignupName: UITextField! { didSet { SignupName.delegate = self } }
    @IBOutlet weak var SignupEmail: UITextField! { didSet { SignupEmail.delegate = self } }

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
    
    /// Triggered once the user confirm the submission.
    /// Checks the validation of inputed email address.
    /// If the address is correct, then make a http request to save the registration info
    ///
    /// :param: nothing
    /// :returns: nothing
    private func confirm() {
        
        if SignupEmail.text.isEmpty {
            showMsg("Please sign up with your email address, thanks.")
            return
        }
        if !isValidEmail(SignupEmail.text) {
            showMsg("Please make sure your email address is correct, thanks.")
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
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    /// Validate the email address
    ///
    /// :param: String input email address
    /// :returns: Bool indicate if the addresss is valid or not
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}
