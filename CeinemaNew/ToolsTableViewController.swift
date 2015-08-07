//
//  ToolsTableViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/13/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

class ToolsTableViewController: UITableViewController {
    
    @IBOutlet var toolsData: UITableView!
    var tools = [SimulationTools]()

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
        
        //Hard coded simulation tools info
        self.tools =  [
            SimulationTools(siTitle: "oPEP", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Nov 2014", siUrl: "http://m.ceitraining.org/app/guidelines/opep/index.jsp"),
            SimulationTools(siTitle: "HIV-Exposed Infant", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Sep 2014", siUrl: "http://m.ceitraining.org/app/guidelines/hiv_exposed_infant/index.jsp"),
            SimulationTools(siTitle: "PrEP", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Aug 2014", siUrl: "http://m.ceitraining.org/app/guidelines/prep/index.jsp"),
            SimulationTools(siTitle: "Anal Dysplasis and Cancer", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Jun 2014", siUrl: "http://m.ceitraining.org/app/guidelines/anal_dysplasia_and_cancer/index.jsp"),
            SimulationTools(siTitle: "HIV Testing", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "May 2014", siUrl: "http://m.ceitraining.org/app/guidelines/hivtesting2/index.jsp"),
            SimulationTools(siTitle: "HIV-2", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "May 2014", siUrl: "http://m.ceitraining.org/app/guidelines/hiv2/index.jsp"),
            SimulationTools(siTitle: "HIV in Older Adults", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Jan 2014", siUrl: "http://m.ceitraining.org/app/guidelines/hiv_older_adults/index.jsp"),
            SimulationTools(siTitle: "Substance Use", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Oct 2013", siUrl: "http://m.ceitraining.org/app/guidelines/substance_use/index.jsp"),
            SimulationTools(siTitle: "Mental Health", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Oct 2012", siUrl: "http://m.ceitraining.org/app/guidelines/mental_health/index.jsp"),
            SimulationTools(siTitle: "Insomnia", siPublisher: "New York State Department of Health AIDS Institute",siPostingDate: "Jun 2013", siUrl: "http://m.ceitraining.org/app/guidelines/insomnia/index.jsp")]
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
        return self.tools.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ToolsTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ToolCell", forIndexPath: indexPath) as! ToolsTableViewCell
        
        let tool = self.tools[indexPath.row]
        
        cell.toolTitle?.text = tool.siTitle
        cell.toolPublisher?.text = tool.siPublisher
        cell.toolPostingDate?.text = tool.siPostingDate
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowToolWebSegue" {
            if let destination = segue.destinationViewController as? ToolsWebViewController {
                if let toolIndex = tableView.indexPathForSelectedRow()?.row {
                    destination.toolUrl = self.tools[toolIndex].siUrl
                }
            }
        }
    }

}
