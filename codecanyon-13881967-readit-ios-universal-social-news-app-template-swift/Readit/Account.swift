/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Account: UIViewController,
UIAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    segControl.selectedSegmentIndex = 0
    newsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    self.title = "\(PFUser.currentUser()!.username!)"
    
    
    // Initialize a LOGOUT BarButton Item (If you're the Current User)
    let butt = UIButton(type: UIButtonType.Custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRectMake(0, 0, 30, 30)
    butt.setBackgroundImage(UIImage(named: "logoutButt"), forState: UIControlState.Normal)
    butt.addTarget(self, action: #selector(logoutButt(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Initialize a BACK BarButton Item
    let backbutt = UIButton(type: UIButtonType.Custom)
    backbutt.adjustsImageWhenHighlighted = false
    backbutt.frame = CGRectMake(0, 0, 30, 30)
    backbutt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    backbutt.addTarget(self, action: #selector(backButton), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutt)
    
    
    // Init ad banners
    initAdMobBanner()
    
    
    // Call query
    queryMyNews()
}

 
// MARK: - QUERY MY NEWS
func queryMyNews() {
    newsArray.removeAll()
    showHUD()
        
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.whereKey(NEWS_USER_POINTER, equalTo: PFUser.currentUser()! )
    query.includeKey(USER_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } }
}
    
 
    
// MARK: - QUERY SAVED NEWS
func querySavedNews() {
    newsArray.removeAll()
    showHUD()
        
    let query = PFQuery(className: SAVED_CLASS_NAME)
    query.whereKey(SAVED_SAVING_USER, equalTo: PFUser.currentUser()!)
    query.includeKey(NEWS_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
                
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
    
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return newsArray.count
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsCell
    
    // SHOW MY NEWS
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[indexPath.row]
        
        // Get userPointer
        let userPointer = newsClass[NEWS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackgroundWithBlock({ (user, error) in
            if error == nil {
                
                // Show User's news
                let aUrl = NSURL(string: "\(newsClass[NEWS_URL]!)")
                var domainStr = aUrl!.host
                if domainStr?.rangeOfString("www.") != nil {
                    domainStr = domainStr!.stringByReplacingOccurrencesOfString("www.", withString: "")
                }
                cell.newsTitleLabel.text = "\(newsClass[NEWS_TITLE]!) (\(domainStr!))"
                cell.newsTitleLabel.layer.cornerRadius = 8
                cell.commentsOutlet.setTitle("\(newsClass[NEWS_COMMENTS])", forState: .Normal)
                cell.categoryOutlet.setTitle("\(newsClass[NEWS_CATEGORY]!)", forState: .Normal)
                let postDate = newsClass.createdAt!
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyy"
                cell.postDateLabel.text = dateFormatter.stringFromDate(postDate)
                
                // Assing tags to the buttons (for later use)
                cell.commentsOutlet.tag = indexPath.row
                cell.shareOutlet.tag = indexPath.row
            }
        })
        
        
        
    // SHOW SAVED NEWS
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[indexPath.row]
        
        // Get userPointer
        let userPointer = savedClass[SAVED_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackgroundWithBlock({ (user, error) in
            // Get newsPointer
            let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
            newsPointer.fetchIfNeededInBackgroundWithBlock({ (news, error) in
                if error == nil {
                    // Show User's news
                    let aUrl = NSURL(string: "\(newsPointer[NEWS_URL]!)")
                    var domainStr = aUrl!.host
                    if domainStr?.rangeOfString("www.") != nil {
                        domainStr = domainStr!.stringByReplacingOccurrencesOfString("www.", withString: "")
                    }
                    cell.newsTitleLabel.text = "\(newsPointer[NEWS_TITLE]!) (\(domainStr!))"
                    cell.newsTitleLabel.layer.cornerRadius = 8
                    cell.commentsOutlet.setTitle("\(newsPointer[NEWS_COMMENTS])", forState: .Normal)
                    cell.categoryOutlet.setTitle("\(newsPointer[NEWS_CATEGORY]!) - by \(userPointer.username!)", forState: .Normal)
                    let postDate = newsPointer.createdAt!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyy"
                    cell.postDateLabel.text = dateFormatter.stringFromDate(postDate)
                    
                    // Assing tags to the buttons (for later use)
                    cell.commentsOutlet.tag = indexPath.row
                    cell.shareOutlet.tag = indexPath.row
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})
        
        })
        
    }
    
return cell
}
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 134
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW NEWS VIA WEB VIEW
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var urlStr = ""
    
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[indexPath.row]
        urlStr = "\(newsClass[NEWS_URL]!)"
        
        // Open MiniBrowser
        let mbVC = storyboard?.instantiateViewControllerWithIdentifier("MiniBrowser") as! MiniBrowser
        mbVC.urlString = urlStr
        navigationController?.pushViewController(mbVC, animated: true)
        
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[indexPath.row]
        // Get newsPointer
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        newsPointer.fetchIfNeededInBackgroundWithBlock({ (news, error) in
            urlStr = "\(newsPointer[NEWS_URL]!)"
            // Open MiniBrowser
            let mbVC = self.storyboard?.instantiateViewControllerWithIdentifier("MiniBrowser") as! MiniBrowser
            mbVC.urlString = urlStr
            self.navigationController?.pushViewController(mbVC, animated: true)
        })
    }
    
}
    
    
    
// MARK: - DELETE NEWS BY SWIPING THE CELL LEFT
func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
            
            var myNewsClass = PFObject(className: NEWS_CLASS_NAME)
            myNewsClass = newsArray[indexPath.row]
            myNewsClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    self.newsArray.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
            }}
        
    }
        
}

    
    
    
    
// MARK: - SWITCH YOUR NEWS / SAVED NEWS
@IBAction func segControlChanged(sender: UISegmentedControl) {
    print("\(segControl.selectedSegmentIndex)")
    
    // SHOW MY NEWS
    if sender.selectedSegmentIndex == 0 {
        newsArray.removeAll()
        newsTableView.reloadData()
        queryMyNews()
        
    // SHOW SAVED NEWS
    } else {
        newsArray.removeAll()
        newsTableView.reloadData()
        querySavedNews()
    }
    
}
    
    
    
// COMMENTS BUTTON
@IBAction func commentsButt(sender: AnyObject) {
    let butt = sender as! UIButton
    
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
        
        let commVC = storyboard?.instantiateViewControllerWithIdentifier("Comments") as! Comments
        commVC.newsObject = newsClass
        navigationController?.pushViewController(commVC, animated: true)
        
    } else {
        var savedClass = PFObject(className: NEWS_CLASS_NAME)
        savedClass = newsArray[butt.tag]
        
        // Get newsPointer
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        newsPointer.fetchIfNeededInBackgroundWithBlock({ (news, error) in
            if error == nil {
                let commVC = self.storyboard?.instantiateViewControllerWithIdentifier("Comments") as! Comments
                commVC.newsObject = newsPointer
                self.navigationController?.pushViewController(commVC, animated: true)
            }
        })
    }
}
    
    
    
   
// MARK: - SHARE BUTTON
@IBAction func shareButt(sender: AnyObject) {
    let butt = sender as! UIButton
    var messageStr = ""
    var img = UIImage()
    
    // SHARE ONE OF YOUR NEWS
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
    
        messageStr  = "\(newsClass[NEWS_TITLE]!) - from #\(APP_NAME)"
        img = UIImage(named: "h1")!
    
        
    // SHARE A SAVED NEWS
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[butt.tag]
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        messageStr  = "\(newsPointer[NEWS_TITLE]!) - from #\(APP_NAME)"
        img = UIImage(named: "h1")!
    }
    
    
    let shareItems = [messageStr, img]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.presentPopoverFromRect(CGRectZero, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    } else {
        // iPhone
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
    
    
    
// MARK: - BACK BUTTON
func backButton() {
    navigationController?.popViewControllerAnimated(true)
}
    
    
    
// MARK: - LOGOUT BUTTON
func logoutButt(sender:UIButton) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to logout?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Yes")
    alert.show()
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Yes" {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if error == nil {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}
    
    

    
    
// MARK: - ADMOB BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 380, 50)
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        
        banner.frame = CGRectMake(0, self.view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRectMake(0, self.view.frame.size.height - banner.frame.size.height,
            banner.frame.size.width, banner.frame.size.height);
        banner.center.x = view.center.x
        
        UIView.commitAnimations()
        banner.hidden = false
        
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



