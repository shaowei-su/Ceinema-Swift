//
//  HomeViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/4/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import QuartzCore

class HomeViewController: UIViewController, UIScrollViewDelegate {


    @IBOutlet weak var visitHomeButton: UIButton!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    var pageWidth: CGFloat? = nil
    var pageHeight: CGFloat? = nil
    
    @IBAction func VisitHomepage(sender: AnyObject) {
        
    }
    
    @IBAction func callCEI(sender: AnyObject) {
        let phone = "tel://8666372342"
        let urlPhone: NSURL = NSURL(string: phone)!
        UIApplication.sharedApplication().openURL(urlPhone)
    }
    
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
        
        //set up the button
        
        // load images into the an array
        pageImages = [UIImage(named:"rsz_cei_logo_redesign-final2013")!,
            UIImage(named:"cei-line.fw")!,
            UIImage(named:"case-simulation-tools.fw")!,
            UIImage(named:"subscribe.fw")!]
        
        let pageCount = pageImages.count
        
        // set up page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount

        pageControl.backgroundColor = UIColor.clearColor()
        // append nil to page views
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // set the content size
        pageWidth = self.view.frame.width - 16.0
        pageHeight = self.pageScrollView.frame.height
        pageScrollView.contentSize = CGSizeMake(pageWidth! * CGFloat(pageImages.count), pageHeight!)
        
        loadVisiblePages()
    }
    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {

            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame.origin.x = pageWidth! * CGFloat(page)
            newPageView.frame.origin.y = 0.0
            newPageView.frame.size = CGSize(width: pageWidth!, height: pageHeight!)
            newPageView.layer.borderWidth = 2.0;
            newPageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            newPageView.layer.cornerRadius = 5.0;
            pageScrollView.addSubview(newPageView)
            
            let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapDetected"))
            singleTap.numberOfTapsRequired = 1
            newPageView.userInteractionEnabled = true
            newPageView.addGestureRecognizer(singleTap)
            
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let page = Int(floor((pageScrollView.contentOffset.x * 2.0 + pageWidth!) / (pageWidth! * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
    {
        //set up the button
        let pageCount = pageControl.numberOfPages
        
        for i in 0..<pageCount {
            purgePage(i)
        }
        
        
        // set the content size
        pageWidth = self.view.frame.width - 16.0
        pageHeight = self.pageScrollView.frame.height
        pageScrollView.contentSize = CGSizeMake(pageWidth! * CGFloat(pageImages.count), pageHeight!)
        pageScrollView.contentOffset.x = 0
        loadVisiblePages()
    }
    
    func tapDetected() {
        let pageCurrent = pageControl.currentPage
        switch pageCurrent {
            case 1:
                let phone = "tel://8666372342"
                let urlPhone: NSURL = NSURL(string: phone)!
                UIApplication.sharedApplication().openURL(urlPhone)
            case 2:
                performSegueWithIdentifier("homeToToolSegue", sender: nil)
            case 3:
                performSegueWithIdentifier("homeToSignupSegue", sender: nil)
            default:
                println("Single Tap on imageview at \(pageCurrent)")
        }
        
    }
}
