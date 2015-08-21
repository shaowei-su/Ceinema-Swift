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

class AllTableViewController: UITableViewController, NSXMLParserDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    
    
    
    @IBOutlet weak var searchDisplay: UISearchBar!
    @IBOutlet var allData: UITableView!
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var mediaTitle = NSMutableString()
    var presenterName = NSMutableString()
    var mediaDateReleased = NSMutableString()
    var mediaThumbPath = NSMutableString()
    var mediaID = NSMutableString()
    
    var filteredPosts = [NSMutableDictionary]()
    var resultSearchController = UISearchController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = reflect(self).summary
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
    
    private func showMsg(msg:String) {
        var alert = UIAlertView(title: "Notice", message: msg, delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }

    
    func preParsing() {
        //use MBProgressHUD to add the loading activity indicator
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
        
        //create a search controller then add to the tableview
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

    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL:(NSURL(string:"http://ceitraining.org/web_services/media.cfc?method=iosGetMedia&sortBy=media_date_released&sortByOrder=DESC")))!
        parser.delegate = self
        parser.parse()
    }
    //XMLParser Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName
        if (elementName as NSString).isEqualToString("row") {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            mediaTitle = NSMutableString.alloc()
            mediaTitle = ""
            presenterName = NSMutableString.alloc()
            presenterName = ""
            mediaDateReleased = NSMutableString.alloc()
            mediaDateReleased = ""
            mediaThumbPath = NSMutableString.alloc()
            mediaThumbPath = ""
            mediaID = NSMutableString.alloc()
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
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if element.isEqualToString("title") {
            mediaTitle.appendString(string!)
        } else if element.isEqualToString("presenterName") {
            presenterName.appendString(string!)
        } else if element.isEqualToString("date") {
            mediaDateReleased.appendString(string!)
        } else if element.isEqualToString("thumbnail") {
            mediaThumbPath.appendString(string!)
        } else if element.isEqualToString("mediaID") {
            mediaID.appendString(string!)
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
        let test = displayPost.valueForKey("presenterName") as! NSString as String
        //trim date format
        cell.mediaDate?.text = displayPost.valueForKey("mediaDateReleased") as! NSString as String
        
        //load image asynchronously
        var imagePath = displayPost.valueForKey("mediaThumbPath") as! NSString as String
        if imagePath.isEmpty {
            cell.mediaImage?.image = UIImage(named: "logo")
        } else {
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                //println(imageURL)
            }
            var escapeImagePath = imagePath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            escapeImagePath = escapeImagePath.stringByReplacingOccurrencesOfString("%0A%20%20%20%20%20%20%20%20%20%20%20%20", withString: "")
            var urlString = NSString(format: "http://www.ceitraining.org/resources/\(escapeImagePath)")
            let imageUrl = NSURL(string: urlString as String)
            cell.mediaImage.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "logo"), completed: block)
            
        }
        
        
        return cell as UITableViewCell
    }
    
    //seque to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMediaSegue" {
            if let navController = segue.destinationViewController as? UINavigationController {
                if let destination = navController.topViewController as? MediaDetailViewController {
                    if self.resultSearchController.active {
                        if let mediaIndex = tableView.indexPathForSelectedRow()?.row {
                            destination.mediaID = filteredPosts[mediaIndex].valueForKey("mediaID") as! NSString as String
                        }
                    } else {
                        if let mediaIndex = tableView.indexPathForSelectedRow()?.row {
                            destination.mediaID = posts.objectAtIndex(mediaIndex).valueForKey("mediaID") as! NSString as String
                        }
                    }
                }
            }
        }
    }
    
    //search function
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
        filterContentForSearchText(searchController.searchBar.text)

        allData.reloadData()
    }
    /*
        interact with webserver whenever finish search
    */
    func willDismissSearchController(searchController: UISearchController) {
        var searchContents = searchController.searchBar.text
        searchContents = searchContents.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let searchString = "http://ceitraining.org/web_services/media.cfc?method=saveSearch&search=" + searchContents
        let url = NSURL(string: searchString)
        println("\(url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
    
    
    @IBAction func refreshTable(sender: UIRefreshControl?) {
        beginParsing()
        sender?.endRefreshing()
    }
}

