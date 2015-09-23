//
//  SavedTableViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/19/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import CoreData
import WebImage

/// Favorites table view controller
///
/// Main functions:
///
/// 1. Load saved favorites to table view
/// 2. Modify Core Data database tuples
/// 3. Seque to lecture detail page
class SavedTableViewController: UITableViewController {
    /// Table view outlet
    @IBOutlet var savedTableView: UITableView!
    /// Core data array
    var media: [NSManagedObject] = []
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Reachability.isConnectedToNetwork() == true {
            try! self.loadData()
        } else {
            showMsg("Please check your internet connection, thanks!")
        }
        
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //add google analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = Mirror(reflecting: self).description
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as! [NSObject : AnyObject])
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
    
    /// Fetch data from Core Data and then reload the table view
    ///
    func loadData() throws {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "LocalSavedMedia" )
        
        media = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        self.savedTableView.reloadData()

    }
    
    override func setEditing(editing: Bool, animated: Bool)  {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return media.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedCell") as! AllTableViewCell
        let mediaCell = media[indexPath.row]
        cell.mediaTitle?.text = mediaCell.valueForKey("mediaTitle") as! String?

        cell.mediaDate?.text = mediaCell.valueForKey("mediaDate") as! String?
        cell.mediaPresentor?.text = mediaCell.valueForKey("presenterName") as! String?
        
        let imagePath = mediaCell.valueForKey("mediaImage") as! String?
        if imagePath!.isEmpty {
            cell.mediaImage?.image = UIImage(named: "logo")
        } else {
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                //println(imageURL)
            }
            let imageUrl = NSURL(string: imagePath! as String)
            cell.mediaImage.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "logo"), completed: block)
            
        }
        
        
        return cell as UITableViewCell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //let mediaItemToDelete = media[indexPath.row]
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(media[indexPath.row] as NSManagedObject)
            self.media.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch _ {
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    ///seque to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSavedMediaSegue" {
            if let destination = segue.destinationViewController as? MediaDetailViewController {
                if let mediaIndex = tableView.indexPathForSelectedRow?.row {
                destination.mediaID = media[mediaIndex].valueForKey("id") as! NSString as String
                }
            }
        }
    }
}
