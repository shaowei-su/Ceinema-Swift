//
//  ToolsTableViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/13/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import SWXMLHash
/// Simulation tools table view controller
///
/// Main functions:
///
/// 1. Load simulation tools from web server thru xml file
/// 2. Segue to tool detail page
class ToolsTableViewController: UITableViewController {
    /// table view outlet
    @IBOutlet var toolsData: UITableView!
    /// xml indexer by SWXMLHash
    var xmlParsed: XMLIndexer?
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
        if Reachability.isConnectedToNetwork() == true {
            beginParsing()
        } else {
            showMsg("Please check your internet connection, thanks!")
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
    
    /// Parse XML file by SWXMLHash. 
    /// After that, eliminate tuples that marked as "hide"
    ///
    ///
    /// - parameter nothing:
    /// - returns: nothing
    func beginParsing() {
        let xmlData = NSData(contentsOfURL: NSURL(string: "http://ceitraining.org/web_services/simulation.cfc?method=getSimulations&hide=0")!)!
        xmlParsed = SWXMLHash.parse(xmlData)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if Reachability.isConnectedToNetwork() == true {
            return xmlParsed!["data"]["row"].all.count
        } else {
            return 0        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ToolsTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ToolCell", forIndexPath: indexPath) as! ToolsTableViewCell

        if let cellTitle = xmlParsed!["data"]["row"][indexPath.row]["simulationTitle"].element?.text {
            cell.toolTitle?.text = cellTitle
        }
        
        if let cellPublisher = xmlParsed!["data"]["row"][indexPath.row]["simulationPublisher"].element?.text {
            cell.toolPublisher?.text = cellPublisher
        }
        if let cellPublishDate = xmlParsed!["data"]["row"][indexPath.row]["simulationDate"].element?.text {
            var cellPublishDateModified = cellPublishDate
            cellPublishDateModified = cellPublishDateModified.stringByReplacingOccurrencesOfString(" 00:00:00.0", withString: "")
            cell.toolPostingDate?.text = cellPublishDateModified
            
            //check for new updates
            let toolDate = cellPublishDateModified.toDate()
            let components = NSDateComponents()
            components.setValue(-3, forComponent: NSCalendarUnit.Month);
            let date: NSDate = NSDate()
            let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
            //print("date: \(toolDate) expireDate: \(expirationDate)")
            let compareOrder = toolDate!.compare(expirationDate!)
            if compareOrder == NSComparisonResult.OrderedDescending {
                cell.toolNewtag.image = UIImage(named: "newtag")
            } else {
                cell.toolNewtag.image = nil
            }
            
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let toolIndex = tableView.indexPathForSelectedRow?.row {
            let shortUrl = xmlParsed!["data"]["row"][toolIndex]["simulationUrl"].element?.text
            let siUrl = NSString(format: "http://m.ceitraining.org/app/guidelines/%@/index.jsp", shortUrl!) as String
            UIApplication.sharedApplication().openURL(NSURL(string: siUrl)!)
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowToolWebSegue" {
//            if let destination = segue.destinationViewController as? ToolsWebViewController {
//                if let toolIndex = tableView.indexPathForSelectedRow?.row {
//                    let shortUrl = xmlParsed!["data"]["row"][toolIndex]["simulationUrl"].element?.text
//                    let siUrl = NSString(format: "http://m.ceitraining.org/app/guidelines/%@/index.jsp", shortUrl!) as String
//                    destination.toolUrl = siUrl
//                }
//            }
//        }
//    }
}



