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

/// Media detail controller
///
/// Main functions
///
/// 1. Load lecture detail thru XML file
/// 2. Play video
/// 3. Save "Favorites" to core data
/// 4. Share thru Activity Controller
/// 5. Report video review to CEI team thru email
class MediaDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    /// media title outlet
    @IBOutlet weak var mediaDetailTitle: UILabel!
    /// media date outlet
    @IBOutlet weak var mediaDateLabel: UILabel!
    /// presenterName outlet
    @IBOutlet weak var presenterNameLabel: UILabel!
    /// presenter title outlet, eg.MD, PHD...
    @IBOutlet weak var presenterTitleLabel: UILabel!
    /// presenter employer outlet, eg. U of R..
    @IBOutlet weak var presenterEmpLabel: UILabel!
    /// media thumbnail image outlet
    @IBOutlet weak var mediaImage: UIImageView!
    /// learning objectives outlet
    @IBOutlet weak var objContentsLabel: UILabel!
    
    /// play button touched, then launch MPVC
    ///
    /// - parameter play: button outlet
    /// - returns: none
    @IBAction func playButtonTouched(sender: UIButton) {
        playMovie()
    }
    /// detail view outlet
    @IBOutlet var mediaDetailView: UIView!
    /// share button outlet
    @IBOutlet weak var shareButton: UIBarButtonItem!
    /// media title
    var mediaTitle: String = ""
    /// media ID
    var mediaID: String = ""
    var mediaDate: String = ""
    var presenterName: String = ""
    var presenterLastName: String = ""
    var presenterCred: String = ""
    /// presenter title, eg. Medical Officer..
    var presenterTitle: String = ""
    var presenterEmp: String = ""
    var imgThumbnail: String = ""
    var videoFormatPath: String = ""
    var videoFormatFileName: String = ""
    var objectives: String = ""
    
    /// url to fetch media detail info thru xml
    var fetchUrl: String = ""
    /// media resources url
    var mediaUrl: String = ""
    /// xml data parsed in
    var xmlData: NSData?
    /// xml indexer from SWXMLHash
    var xmlParsed: XMLIndexer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = Mirror(reflecting: self).description.stringByReplacingOccurrencesOfString("Mirror for ", withString: "")
            //print("Screen name: \(screenName)")
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    
    /// add MPVC to the view
    ///
    /// - parameter nothing:
    /// - returns: nothing
    func playMovie() {
        
        let mpController = MPMoviePlayerViewController(contentURL: NSURL(string: mediaUrl))
        self.navigationController?.presentMoviePlayerViewControllerAnimated(mpController)
        self.view.addSubview(mpController.view)
        
        
    }
    
    @IBAction func contactButton(sender: AnyObject) {
        let alert = UIAlertController(title: "Email to CEI team", message: "Report an issue or a brief review of this lecture to CEI team", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Email",
            style: .Default) { (action: UIAlertAction) -> Void in
                self.emailCEI()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// compose email to CEI support team
    ///
    /// - parameter nothing:
    /// - returns: nothing
    func emailCEI() {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
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
        print("mediaid = \(mediaID)")
        beginParsing()
        videoFormatFileName = videoFormatFileName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        //videoFormatFileName = videoFormatFileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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
    
    /// Parse XML file by SWXMLHash.
    /// Then demonstrate parsed info on media detail page
    ///
    /// - parameter nothing:
    /// - returns: nothing
    func beginParsing() {
        mediaID = mediaID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        //mediaID = mediaID.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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
            let mediaImageThumb = mediaImageThumbRead
            if mediaImageThumb.isEmpty {
                print("load image failed")
            } else {
                let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                    //println(imageURL)
                }
                var escapeImagePath = mediaImageThumb.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
                //var escapeImagePath = mediaImageThumb.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                escapeImagePath = escapeImagePath.stringByReplacingOccurrencesOfString("%0A%20%20%20%20%20%20%20%20%20%20%20%20", withString: "")
                let urlString = NSString(format: "http://www.ceitraining.org/resources/\(escapeImagePath)")
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
        let alert = UIAlertController(title: "Save to favorites", message: "Add this course for future review", preferredStyle: .Alert)
        
//        let saveAction = UIAlertAction(title: "Save", style: .Default) { (alert: UIAlertAction!) -> Void in
//                try self.saveMedia(self.mediaTitle, presenter: self.presenterName, date: self.mediaDate, imageThumbnail: self.imgThumbnail, id: self.mediaID)
//        }
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                self.saveMedia(self.mediaTitle, presenter: self.presenterName, date: self.mediaDate, imageThumbnail: self.imgThumbnail, id: self.mediaID)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Once the user press save button:
    ///
    /// 1. Trigger html request to save the media ID
    /// 2. Save media info into Core Data
    ///
    /// - parameter title: The title of one media
    /// - parameter presenter: Full name of the presenter
    /// - parameter date: Date of the presentation
    /// - parameter imageThumbnail: Short url of thumbnail image
    /// - returns: nothing
    func saveMedia(title: String, presenter: String, date: String, imageThumbnail: String, id: String) {
        //save mediaID to web sever
        var idContent = id
        idContent = idContent.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        //idContent = idContent.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let idString = "http://ceitraining.org/web_services/media.cfc?method=saveFavorite&mediaID=" + idContent
        let url = NSURL(string: idString)
        //print("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
        //save to Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("LocalSavedMedia", inManagedObjectContext: managedContext)
    
        
        do {
            try managedContext.save()
        } catch {
            print("error when save")
        }
        //remove duplications before save
        let fetchRequestDup = NSFetchRequest(entityName: "LocalSavedMedia")
        fetchRequestDup.includesSubentities = false
        fetchRequestDup.returnsObjectsAsFaults = false
        
        fetchRequestDup.predicate = NSPredicate(format:"id == '\(id)'")
        
        // managedContext is your NSManagedObjectContext here
        let items = try! managedContext.executeFetchRequest(fetchRequestDup)
        
        for item in items {
            managedContext.deleteObject(item as! NSManagedObject)
        }
        
        let mediaTuple = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        mediaTuple.setValue(title, forKey: "mediaTitle")
        mediaTuple.setValue(id, forKey: "id")
        mediaTuple.setValue(presenter, forKey: "presenterName")
        mediaTuple.setValue(date, forKey: "mediaDate")
        mediaTuple.setValue(imageThumbnail, forKey: "mediaImage")
        
        do {
            try managedContext.save()
        } catch _ {
        }
    }
    
    /// Verify the media video url to see if WOWZA media server is working
    /// 
    /// - parameter urlString: Completed video url
    /// - returns: true / false
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                if let _ = NSData(contentsOfURL: url) {
                    return true
                }
            }
        }
        return false
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?){
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Saved")
        case MFMailComposeResultSent.rawValue:
            print("Sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail send Failed: \(error!.localizedDescription)")
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
