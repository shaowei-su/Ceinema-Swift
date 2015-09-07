//
//  ToolsTableViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/13/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import SWXMLHash

class ToolsTableViewController: UITableViewController {
    
    @IBOutlet var toolsData: UITableView!
    var xmlParsed: XMLIndexer?
    var toolCounter = 0
    var toolMap = Dictionary<Int, Int>()
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = reflect(self).summary
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
    
    private func showMsg(msg:String) {
        var alert = UIAlertView(title: "Notice", message: msg, delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }
    
    /// Parse XML file by SWXMLHash. 
    /// After that, eliminate tuples that marked as "hide"
    /// The map "toolmap" will map the index in table view to the index in parsed XML Indexer
    ///
    /// :param: nothing
    /// :returns: nothing
    func beginParsing() {
        let xmlData = NSData(contentsOfURL: NSURL(string: "http://ceitraining.org/xml/live/simulations.xml")!)!
        xmlParsed = SWXMLHash.parse(xmlData)
        //to map the actual index with the row index
        //toolCounter indicates the real number of rows
        var index = 0
        for elem in xmlParsed!["simulations"]["simulation"] {
            if elem["hide"].element?.text != "true" {
                toolMap[toolCounter] = index
                toolCounter++
            }
            index++
        }
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
        return toolCounter
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ToolsTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ToolCell", forIndexPath: indexPath) as! ToolsTableViewCell
        var rowIndex = toolMap[indexPath.row]!

        if let cellTitle = xmlParsed!["simulations"]["simulation"][rowIndex]["simulation_short_title"].element?.text {
            cell.toolTitle?.text = cellTitle
        }
        
        if let cellPublisher = xmlParsed!["simulations"]["simulation"][rowIndex]["publisher"].element?.text {
            cell.toolPublisher?.text = cellPublisher
        }
        if let cellPublishDate = xmlParsed!["simulations"]["simulation"][rowIndex]["tool_released_date"].element?.text {
            var cellPublishDateModified = cellPublishDate
            cellPublishDateModified = cellPublishDateModified.stringByReplacingOccurrencesOfString("T00:00:00", withString: "")
            cell.toolPostingDate?.text = cellPublishDateModified
        }
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowToolWebSegue" {
            if let destination = segue.destinationViewController as? ToolsWebViewController {
                if let toolIndex = tableView.indexPathForSelectedRow()?.row {
                    let toolIndexModified = toolMap[toolIndex]!
                    let shortUrl = xmlParsed!["simulations"]["simulation"][toolIndexModified]["simulation_url"].element?.text
                    let siUrl = NSString(format: "http://m.ceitraining.org/app/guidelines/%@/index.jsp", shortUrl!) as String
                    //destination.toolUrl = self.tools[toolIndex].siUrl
                    destination.toolUrl = siUrl
                }
            }
        }
    }

}
