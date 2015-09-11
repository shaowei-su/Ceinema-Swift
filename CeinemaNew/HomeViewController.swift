//
//  HomeViewController.swift
//  CeinemaNew
//
//  Created by shaowei on 7/4/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit
import QuartzCore

class HomeViewController: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {


    @IBOutlet weak var visitHomeButton: UIButton!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    var pageWidth: CGFloat? = nil
    var pageHeight: CGFloat? = nil
    
    @IBAction func VisitHomepage(sender: AnyObject) {
        
    }
    
    /// Call CEI line when the "call" button touched
    ///
    /// :param: AnyObject passed in from storyboard
    /// :returns: nothing
    @IBAction func callCEI(sender: AnyObject) {
        let phone = "tel://8666372342"
        let urlPhone: NSURL = NSURL(string: phone)!
        UIApplication.sharedApplication().openURL(urlPhone)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ///add Google Analytics
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let screenName = reflect(self).summary
            let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as NSDictionary
            appDelegate.tracker!.send(build as [NSObject : AnyObject])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the button
        self.tabBarController?.delegate = self
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
        //set up NSTimer to auto rotate pages every 4 seconds
        NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
    }
    
    /// Move the carousel pages automatically to the next page.
    /// To the first page if the reaches the end
    ///
    /// :param: nothing
    /// :returns: nothing
    func moveToNextPage (){
        
        var pageWidth:CGFloat = CGRectGetWidth(self.pageScrollView.frame)
        let maxWidth:CGFloat = pageWidth * 4
        var contentOffset:CGFloat = self.pageScrollView.contentOffset.x
        //move to next page, to the begining if reach the tail
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        self.pageScrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.pageScrollView.frame)), animated: true)
    }
    
    /// Dynamically load pageview on the paged scroll view
    ///
    /// :param: int one int number indicate the position of current page
    /// :returns: nothing
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
    
    /// Remove a page from the scroll view and reset the container array
    ///
    /// :param: int one int number indicate the position of current page
    /// :returns: nothing
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    /// Dynamically load current page on scroll view.
    /// After determining the position, call loadPage() and purgePage().
    ///
    /// :param: nothing
    /// :returns: nothing
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
    
    /// Detect the tap event and trigger following behaviors
    ///
    /// For different pages:
    ///
    /// 1. Page two: call cei line
    /// 2. Page three: perform segue and move the the tools page
    /// 3. page four: perform segue and move to newsletter sign up page
    ///
    /// :param: nothing
    /// :returns: nothing
    func tapDetected() {
        let pageCurrent = pageControl.currentPage
        switch pageCurrent {
            case 1:
                let phone = "tel://8666372342"
                let urlPhone: NSURL = NSURL(string: phone)!
                UIApplication.sharedApplication().openURL(urlPhone)
            case 2:
                //performSegueWithIdentifier("homeToToolSegue", sender: nil)
                switch2ToolTab()
            case 3:
                performSegueWithIdentifier("homeToSignupSegue", sender: nil)
            default:
                println("Single Tap on imageview at \(pageCurrent)")
        }
        
    }
    
    /// Switch top view to the tab bar: 2
    ///
    /// :param: none
    /// :returns: none
    func switch2ToolTab() {
        self.tabBarController!.selectedIndex = 2
    }
    
    /// Pop navigation stack to the root when "Home" tabed
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if (tabBarController.selectedIndex == 0) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}
