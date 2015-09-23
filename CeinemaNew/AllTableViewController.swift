//
//  AllTableViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/5/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import WebImage
import Foundation

/// Controller of lecture table view.
/// 
/// Main functions:
///
/// 1. Load table view with lectures info parsed from web server
/// 2. Search controller supports user defined search
/// 3. Drag Down refresh
/// 4. Segue to lecture detail page
class AllTableViewController: UITableViewController, NSXMLParserDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    
    
    /// search bar outlet
    @IBOutlet weak var searchDisplay: UISearchBar!
    /// table view outlet
    @IBOutlet var allData: UITableView!
    /// xml parser
    var parser = NSXMLParser()
    /// posts contains all parsed lecture info (multiple key-value pairs saved in elements)
    var posts = NSMutableArray()
    /// multiple key-value pairs saved in elements
    var elements = NSMutableDictionary()
    /// element stores xml file element name parsed in
    var element = NSString()
    /// mediaTitle parsed in
    var mediaTitle = NSMutableString()
    /// presenterName parsed in
    var presenterName = NSMutableString()
    /// mediaDateReleased parsed in
    var mediaDateReleased = NSMutableString()
    /// mediaThumbPath parsed in
    var mediaThumbPath = NSMutableString()
    /// mediaID parsed in
    var mediaID = NSMutableString()
    /// contains lectures that are filtered by search controller
    var filteredPosts = [NSMutableDictionary]()
    /// search controller for user defined search
    var resultSearchController: UISearchController = UISearchController()
    
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //remove search bar when view changes
        if self.resultSearchController.active {
            self.resultSearchController.active = false
            self.resultSearchController.searchBar.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() == true {
            preParsing()
        } else {
            showMsg("Please check your internet connection, thanks!")
        }
        
    }
    
    /// Show notification messages
    ///
    /// - parameter msg: message string that needs to be demonstrated
    /// - returns: none
    private func showMsg(msg:String) {
        let alert = UIAlertView(title: "Notice", message: msg, delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }

    /// Two main operations:
    ///
    /// 1. Use MBProgressHUD to add the loading activity indicator, start parse() with a separate queue at background.
    /// 2. Create a search controller then add to the tableview
    ///
    /// - parameter nothing:
    /// - returns: nothing
    func preParsing() {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        UIApplication.sharedApplication().keyWindow?.addSubview(loadingNotification)
        loadingNotification.labelText = "Loading"
        loadingNotification.detailsLabelText = "Please wait..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            self.beginParsing()
            dispatch_async(dispatch_get_main_queue()) {
                loadingNotification.hide(true)
                self.allData.reloadData()
            }
        }
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.delegate = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }

    /// begin parse with NSXMLParser()
    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL:(NSURL(string:"http://ceitraining.org/web_services/media.cfc?method=iosGetMedia&sortBy=media_date_released&sortByOrder=DESC"))!)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if (elementName as NSString).isEqualToString("row") {
            elements = NSMutableDictionary()
            elements = [:]
            mediaTitle = NSMutableString()
            mediaTitle = ""
            presenterName = NSMutableString()
            presenterName = ""
            mediaDateReleased = NSMutableString()
            mediaDateReleased = ""
            mediaThumbPath = NSMutableString()
            mediaThumbPath = ""
            mediaID = NSMutableString()
            mediaID = ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("row") {
            if !mediaTitle.isEqual(nil) {
                elements.setObject(mediaTitle, forKey: "mediaTitle")
            }
            if !presenterName.isEqual(nil) {
                elements.setObject(presenterName, forKey: "presenterName")
            }
            if !mediaDateReleased.isEqual(nil) {
                elements.setObject(mediaDateReleased, forKey: "mediaDateReleased")
            }
            if !mediaThumbPath.isEqual(nil) {
                elements.setObject(mediaThumbPath, forKey: "mediaThumbPath")
            }
            if !mediaID.isEqual(nil) {
                elements.setObject(mediaID, forKey: "mediaID")
            }
            if !posts.containsObject(elements) {
                posts.addObject(elements)
            }
            
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if element.isEqualToString("title") {
            mediaTitle.appendString(string)
        } else if element.isEqualToString("presenterName") {
            presenterName.appendString(string)
        } else if element.isEqualToString("date") {
            mediaDateReleased.appendString(string)
        } else if element.isEqualToString("thumbnail") {
            mediaThumbPath.appendString(string)
        } else if element.isEqualToString("mediaID") {
            mediaID.appendString(string)
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if self.resultSearchController.active {
            return self.filteredPosts.count
        } else {
            return posts.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AllTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AllTableViewCell
        var displayPost: NSMutableDictionary
        if self.resultSearchController.active {
            displayPost = filteredPosts[indexPath.row]
        } else {
            displayPost = posts.objectAtIndex(indexPath.row) as! NSMutableDictionary
        }
        
        
        cell.mediaTitle?.text = displayPost.valueForKey("mediaTitle") as! NSString as String
        //check if there exists multiple presenters and then adjust the number of lines
        var presenterNameRead = displayPost.valueForKey("presenterName") as! NSString as String
        cell.mediaPresentor?.numberOfLines = 1
        if presenterNameRead.rangeOfString("|") != nil {
            cell.mediaPresentor?.numberOfLines = 2
            presenterNameRead = presenterNameRead.stringByReplacingOccurrencesOfString("|", withString: "\n")
        }
        cell.mediaPresentor?.text = presenterNameRead
        _ = displayPost.valueForKey("presenterName") as! NSString as String
        //trim date format
        cell.mediaDate?.text = displayPost.valueForKey("mediaDateReleased") as! NSString as String
        
        //convert date format
        let dateUnSeperated = displayPost.valueForKey("mediaDateReleased") as! NSString as String
        var dateSeperated = dateUnSeperated.characters.split {$0 == " "}.map { String($0) }
        switch dateSeperated[0] as String {
            case "Dec":
                dateSeperated[0] = "12"
            case "Nov":
                dateSeperated[0] = "11"
            case "Oct":
                dateSeperated[0] = "10"
            case "Sep":
                dateSeperated[0] = "09"
            case "Aug":
                dateSeperated[0] = "08"
            case "Jul":
                dateSeperated[0] = "07"
            case "Jun":
                dateSeperated[0] = "06"
            case "May":
                dateSeperated[0] = "05"
            case "Apr":
                dateSeperated[0] = "04"
            case "Mar":
                dateSeperated[0] = "03"
            case "Feb":
                dateSeperated[0] = "02"
            case "Jan":
                dateSeperated[0] = "01"
            default:
                break
        }
        dateSeperated[1] = dateSeperated[1].stringByReplacingOccurrencesOfString(",", withString: "")
        //print("mon = \(dateSeperated[0]) day = \(dateSeperated[1]) year = \(dateSeperated[2])")
        //check for new updates
        let toolDate = (dateSeperated[2] + "-" + dateSeperated[0] + "-" + dateSeperated[1]).toDate()
        let components = NSDateComponents()
        components.setValue(-1, forComponent: NSCalendarUnit.Month);
        let date: NSDate = NSDate()
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
        //print("date: \(toolDate) expireDate: \(expirationDate)")
        let compareOrder = toolDate!.compare(expirationDate!)
        if compareOrder == NSComparisonResult.OrderedDescending {
            cell.mediaNewTag.image = UIImage(named: "newtag")
        } else {
            cell.mediaNewTag.image = nil
        }
        //load image asynchronously
        let imagePath = displayPost.valueForKey("mediaThumbPath") as! NSString as String
        if imagePath.isEmpty {
            cell.mediaImage?.image = UIImage(named: "logo")
        } else {
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                //println(imageURL)
            }
            var escapeImagePath = imagePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
            //var escapeImagePath = imagePath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            escapeImagePath = escapeImagePath.stringByReplacingOccurrencesOfString("%0A%20%20%20%20%20%20%20%20%20%20%20%20", withString: "")
            let urlString = NSString(format: "http://www.ceitraining.org/resources/\(escapeImagePath)")
            let imageUrl = NSURL(string: urlString as String)
            cell.mediaImage.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "logo"), completed: block)
            
        }
        
        
        return cell as UITableViewCell
    }
    
    //seque to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMediaSegue" {
            if let destination = segue.destinationViewController as? MediaDetailViewController {
                if self.resultSearchController.active {
                    if let mediaIndex = tableView.indexPathForSelectedRow?.row {
                        destination.mediaID = filteredPosts[mediaIndex].valueForKey("mediaID") as! NSString as String
                    }
                } else {
                    if let mediaIndex = tableView.indexPathForSelectedRow?.row {
                        destination.mediaID = posts.objectAtIndex(mediaIndex).valueForKey("mediaID") as! NSString as String
                    }
                }
            }
        }
    }
    
    /// Search function support.
    /// Split input string by " "(empty space) for multiple search.
    /// Keywords match both media title and presenter name
    ///
    /// - parameter String: user input string
    /// - returns: nothing
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        let postsArray = posts as AnyObject as! [NSMutableDictionary]
        self.filteredPosts = postsArray.filter({( elements: NSMutableDictionary) -> Bool in
            let searchTitle = elements.valueForKey("mediaTitle")! as! NSString as String
            let searchPresenterFirstName = elements.valueForKey("presenterName")! as! NSString as String
            //split string to check for multiple inputs
            var searchTextModified = searchText.lowercaseString.componentsSeparatedByString(" ")
            var stringMatchTitle: Range<String.Index>?
            var stringMatchPresenterFirstName: Range<String.Index>?
            for i in 0..<searchTextModified.count {
                if stringMatchTitle != nil {
                    break
                }
                stringMatchTitle = searchTitle.lowercaseString.rangeOfString(searchTextModified[i])
            }
            for i in 0..<searchTextModified.count {
                if stringMatchPresenterFirstName != nil {
                    break
                }
                stringMatchPresenterFirstName = searchPresenterFirstName.lowercaseString.rangeOfString(searchTextModified[i])
            }
            return (stringMatchTitle != nil || stringMatchPresenterFirstName != nil)
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredPosts.removeAll(keepCapacity: false)
        filterContentForSearchText(searchController.searchBar.text!)

        allData.reloadData()
    }
    
    /// Interact with webserver whenever finish search
    func willDismissSearchController(searchController: UISearchController) {
        var searchContents = searchController.searchBar.text
        searchContents = searchContents!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        //searchContents = searchContents!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let searchString = "http://ceitraining.org/web_services/media.cfc?method=saveSearch&search=" + searchContents!
        let url = NSURL(string: searchString)
        print("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
    
    
    @IBAction func refreshTable(sender: UIRefreshControl?) {
        beginParsing()
        sender?.endRefreshing()
    }
}

extension String {
    /// Extension of String to easily convert from string to date
    ///
    /// - parameter format: string the format of inputed string date
    /// - returns: NSDate the NSDate generated
    func toDate(let format:String = "yyyy-MM-dd") -> NSDate? {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        
        return formatter.dateFromString(self)
    }
}

