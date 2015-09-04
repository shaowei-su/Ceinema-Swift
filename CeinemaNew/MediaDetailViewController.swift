//
//  MediaDetailViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/12/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import MediaPlayer
import SWXMLHash
import WebImage
import CoreData
import Foundation
import MessageUI
import Social
import MobileCoreServices

class MediaDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mediaDetailTitle: UILabel!
    
    @IBOutlet weak var mediaDateLabel: UILabel!
    @IBOutlet weak var presenterNameLabel: UILabel!
    @IBOutlet weak var presenterTitleLabel: UILabel!
    @IBOutlet weak var presenterEmpLabel: UILabel!
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var objContentsLabel: UILabel!
    @IBAction func playButtonTouched(sender: UIButton) {
        playMovie()
    }
    @IBOutlet var mediaDetailView: UIView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var mediaTitle: String = ""
    var mediaID: String = ""
    var mediaDate: String = ""
    var presenterName: String = ""
    var presenterLastName: String = ""
    var presenterCred: String = ""
    var presenterTitle: String = ""
    var presenterEmp: String = ""
    var imgThumbnail: String = ""
    var videoFormatPath: String = ""
    var videoFormatFileName: String = ""
    var objectives: String = ""
    
    
    var fetchUrl: String = ""
    var mediaUrl: String = ""
    
    var xmlData: NSData?
    var xmlParsed: XMLIndexer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = reflect(self).summary
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    
    func playMovie() {
        
        let mpController = MPMoviePlayerViewController(contentURL: NSURL(string: mediaUrl))
        self.navigationController?.presentMoviePlayerViewControllerAnimated(mpController)
        self.view.addSubview(mpController.view)
        
        
    }
    
    @IBAction func contactButton(sender: AnyObject) {
        var alert = UIAlertController(title: "Email to CEI team", message: "Report an issue or a brief review of this lecture to CEI team", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Email",
            style: .Default) { (action: UIAlertAction!) -> Void in
                self.emailCEI()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func emailCEI() {
        if MFMailComposeViewController.canSendMail() {
            var composer = MFMailComposeViewController()
            composer.delegate = self
            composer.mailComposeDelegate = self
            composer.setToRecipients(["support@ceitraining.org"])
            composer.setSubject("iOS video report about \(mediaTitle)")
            composer.navigationBar.tintColor = UIColor.whiteColor()
            self.presentViewController(composer, animated: true, completion: { () -> Void in
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        beginParsing()
        
        videoFormatFileName = videoFormatFileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        videoFormatFileName = videoFormatFileName.stringByReplacingOccurrencesOfString("_high.3gp", withString: "")
        videoFormatFileName = videoFormatFileName.stringByReplacingOccurrencesOfString("_low.3gp", withString: "")
        videoFormatFileName = videoFormatFileName.stringByReplacingOccurrencesOfString("%0A%20%20%20%20", withString: "")
        mediaUrl = NSString(format: "http://ceiconnect.org:1936/vod/definst/smil:%@/%@.smil/playlist.m3u8", videoFormatFileName, videoFormatFileName) as String
        if verifyUrl(mediaUrl) {
            //println("wowza working")
        } else {
            //println("wowza not working")
            mediaUrl = NSString(format: "http://ceitraining.org/media/video/mobile/HTTP_streaming/%@/%@.m3u8", videoFormatFileName, videoFormatFileName) as String
        }
    }
    
    
    func beginParsing() {
        mediaID = mediaID.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        mediaID = mediaID.stringByReplacingOccurrencesOfString("%0A%20%20%20%20%20%20%20%20%20%20%20%20", withString: "")
        fetchUrl = NSString(format: "http://ceitraining.org/web_services/media.cfc?method=iosGetSingleMedium&mediaID=%@", mediaID) as String
        xmlData = NSData(contentsOfURL: NSURL(string: fetchUrl)!)!
        xmlParsed = SWXMLHash.parse(xmlData!)

        if let mediaTitleRead = xmlParsed!["data"]["row"]["title"].element?.text {
            mediaTitle = mediaTitleRead
            mediaDetailTitle.text = mediaTitleRead
        }
        if let videoFormatFileNameRead = xmlParsed!["data"]["row"]["formatFileName"].element?.text {
            videoFormatFileName = videoFormatFileNameRead
        }
        if let mediaDateLabelRead = xmlParsed!["data"]["row"]["date"].element?.text {
            mediaDateLabel.text = mediaDateLabelRead
            mediaDate = mediaDateLabelRead
        }
        if let mediaPresenterRead = xmlParsed!["data"]["row"]["presenter"].element?.text {
            var mediaPresenter = mediaPresenterRead
            mediaPresenter = mediaPresenter.stringByReplacingOccurrencesOfString("|", withString: "\n\n")
            mediaPresenter = mediaPresenter.stringByReplacingOccurrencesOfString("$$", withString: "\n")
            mediaPresenter = mediaPresenter.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
            mediaPresenter = mediaPresenter.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
            presenterEmpLabel.text = mediaPresenter
            presenterName = mediaPresenter
        }
        if let objContentsRead = xmlParsed!["data"]["row"]["objectives"].element?.text {
            var objContents = objContentsRead
            objContents = objContents.stringByReplacingOccurrencesOfString("|", withString: "\n\u{2022}")
            objContentsLabel.text = "\u{2022}" + objContents
        } else {
            objContentsLabel.text = "\u{2022}" + "Learning objectives are not available."
        }
        
        if let mediaImageThumbRead = xmlParsed!["data"]["row"]["thumbnail"].element?.text {
            var mediaImageThumb = mediaImageThumbRead
            if mediaImageThumb.isEmpty {
                println("load image failed")
            } else {
                let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    //println(imageURL)
                }
                var escapeImagePath = mediaImageThumb.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                escapeImagePath = escapeImagePath.stringByReplacingOccurrencesOfString("%0A%20%20%20%20%20%20%20%20%20%20%20%20", withString: "")
                var urlString = NSString(format: "http://www.ceitraining.org/resources/\(escapeImagePath)")
                imgThumbnail = urlString as String
                let imageUrl = NSURL(string: urlString as String)
                mediaImage.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "logo"), completed: block)
                mediaImage.layer.cornerRadius = 5.0
                mediaImage.clipsToBounds = true
                mediaImage.layer.borderColor = UIColor.blackColor().CGColor
                mediaImage.layer.borderWidth = 2.0
            }
            
        }
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        var alert = UIAlertController(title: "Save to favorites", message: "Add this course for future review", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                self.saveMedia(self.mediaTitle, presenter: self.presenterName, date: self.mediaDate, imageThumbnail: self.imgThumbnail, id: self.mediaID)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveMedia(title: String, presenter: String, date: String, imageThumbnail: String, id: String) {
        //save mediaID to web sever
        var idContent = id
        idContent = idContent.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let idString = "http://ceitraining.org/web_services/media.cfc?method=saveFavorite&mediaID=" + idContent
        let url = NSURL(string: idString)
        println("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
        //save to Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("LocalSavedMedia", inManagedObjectContext: managedContext)
        
        
        var error: NSError?
        
        if !managedContext.save(&error) {
            println("error when save")
        }
        //remove duplications before save
        let fetchRequestDup = NSFetchRequest(entityName: "LocalSavedMedia")
        fetchRequestDup.includesSubentities = false
        fetchRequestDup.returnsObjectsAsFaults = false
        
        fetchRequestDup.predicate = NSPredicate(format:"id == '\(id)'")
        
        // managedContext is your NSManagedObjectContext here
        let items = managedContext.executeFetchRequest(fetchRequestDup, error: &error)!
        
        for item in items {
            managedContext.deleteObject(item as! NSManagedObject)
        }
        
        let mediaTuple = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        mediaTuple.setValue(title, forKey: "mediaTitle")
        mediaTuple.setValue(id, forKey: "id")
        mediaTuple.setValue(presenter, forKey: "presenterName")
        mediaTuple.setValue(date, forKey: "mediaDate")
        mediaTuple.setValue(imageThumbnail, forKey: "mediaImage")
        
        managedContext.save(nil)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                if let urlData = NSData(contentsOfURL: url) {
                    return true
                }
            }
        }
        return false
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!){
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Cancelled")
        case MFMailComposeResultSaved.value:
            println("Saved")
        case MFMailComposeResultSent.value:
            println("Sent")
        case MFMailComposeResultFailed.value:
            println("Mail send Failed: \(error.localizedDescription)")
        default:
            break
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostSocialMedia(sender: AnyObject) {
        var activityItems: [AnyObject]?
        //let postContent = "\(mediaTitle) by \(presenterName) \(presenterLastName)\(presenterCred) http://ceitraining.org/resources/audio-video-detail.cfm?mediaID=\(mediaID)"
        let postContent = NSString(format: "%@ by %@ http://ceitraining.org/resources/audio-video-detail.cfm?mediaID=%@", mediaTitle, presenterName, mediaID) as String!
        let imageUrl = NSURL(string: imgThumbnail)
        let postImage = UIImage(data: NSData(contentsOfURL: imageUrl!)!)
        activityItems = [postContent, postImage!]
        
        let activityController = UIActivityViewController(activityItems: activityItems!, applicationActivities: nil)

        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            // go on..
        } else {
            //if iPad
            if activityController.respondsToSelector(Selector("popoverPresentationController")) {
                // on iOS8
                activityController.popoverPresentationController!.barButtonItem = self.shareButton;
            }
        }
        self.presentViewController(activityController, animated: true, completion: nil)
        
    }
}
