/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import MessageUI
import GoogleMobileAds
import AudioToolbox



// MARK: - CUSTOM NEWS CELL
class NewsCell: UITableViewCell {
    
    /* Views */
    @IBOutlet weak var upVoteOutlet: UIButton!
    @IBOutlet weak var downVoteOutlet: UIButton!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var submittedByOutlet: UIButton!
    @IBOutlet weak var commentsOutlet: UIButton!
    @IBOutlet weak var categoryOutlet: UIButton!
    @IBOutlet weak var shareOutlet: UIButton!
    @IBOutlet weak var saveOutlet: UIButton!
    @IBOutlet weak var reportOutlet: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    
    
    /* Variables */
    var upVoted = Bool()
    var downVoted = Bool()
}









// MARK: - HOME CONTROLLER
class Home: UIViewController,
UIAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
MFMailComposeViewControllerDelegate,
GADBannerViewDelegate,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBOutlet weak var sortView: UIView!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    var categoriesArray = [PFObject]()
    var savedNews = [PFObject]()
    var votesArray = [PFObject]()
    
    var categoryStr = ""
    var userID = ""
    var searchText = ""
    var searchViewiSVisible = false
    var sortViewIsVisible = false
    var sortByDate = true
    var sortByVotes = false
    
    
    
    
    
    
    
override func viewWillAppear(animated: Bool) {

    // Hide views
    searchView.frame.origin.y = -searchView.frame.size.height
    searchViewiSVisible = false
    sortView.frame.origin.y = -sortView.frame.size.height
    sortViewIsVisible = false
    
    // Call query News
    callQueryNews()
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    
    let logo = UIImage(named: "navbar.png")
    let imageView = UIImageView(image:logo)
    self.navigationItem.titleView = imageView
    
    
    
    // Layouts
    newsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    // Init ad banners
    initAdMobBanner()
    
    
}

    
    
// MARK: - CALL QUERY TO NEWS
func callQueryNews() {
    if categoryStr != ""       { queryNews(categoryStr)
    } else if userID != ""     { queryNews(userID)
    } else if searchText != "" { queryNews(searchText)
    } else if categoryStr == ""  && userID == ""  && searchText == "" { queryNews("") }
    
    // CONSOLE LOGS:
    print("\n\nSORT BY DATE: \(sortByDate)")
    print("SORT BY VOTES: \(sortByVotes)")
    print("CATEGORY: \(categoryStr)")
    print("USER ID: \(userID)")
    print("SEARCH TEXT: \(searchText)\n\n")
}

    
    
// MARK: - QUERY NEWS
func queryNews(text:String) {
    newsArray.removeAll()
    showHUD()
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.limit = 100
    query.includeKey(USER_CLASS_NAME)
    
    // Query by Category
    if categoryStr != "" { query.whereKey(NEWS_CATEGORY, equalTo: text)
    } else { self.title = "Latest" }

    // Query by User
    if userID != "" { query.whereKey(NEWS_USER_POINTER, equalTo: PFObject(outDataWithClassName: USER_CLASS_NAME, objectId: userID) )
    } else { self.title = "Latest" }
    
    // Query by Search text
    if searchText != "" {
        let keywords = searchText.componentsSeparatedByString(" ") as [String]
        query.whereKey(NEWS_TITLE_LOWERCASE, containsString: keywords[0].lowercaseString)
    } else { self.title = "Latest" }
    
    // Sort by Date or Votes (by Date is the default ordering when view will appear)
    if sortByDate { query.orderByDescending("createdAt")
    } else if sortByVotes { query.orderByDescending(NEWS_VOTES) }
    
    
    // Query block
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
            self.queryCategories()
        
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
// MARK: - QUERY CATEGORIES
func queryCategories() {
    categoriesArray.removeAll()

    let query = PFQuery(className: CATEGORIES_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.categoriesArray = objects!
            self.showCategories()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")

    }}
}
    
// SHOW CATEGORIES INTO THE TOP SCROLLVIEW
func showCategories() {
    // Variables for setting the Font Buttons
    var xCoord: CGFloat = 0
    let yCoord: CGFloat = 0
    let buttonWidth:CGFloat = 90
    let buttonHeight: CGFloat = 44
    let gap: CGFloat = 0
    
    // Counter for items
    var itemCount = 0
    
    // Loop for creating buttons -----------------
    for i in 0..<categoriesArray.count {
        itemCount = i

        var catClass = PFObject(className: CATEGORIES_CLASS_NAME)
        catClass = categoriesArray[itemCount]
        
        // Create a Button
        let myButt = UIButton(type: UIButtonType.Custom)
        myButt.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight)
        myButt.tag = itemCount
        myButt.showsTouchWhenHighlighted = true
        myButt.setTitle("\(catClass[CATEGORIES_CATEGORY]!)", forState: .Normal)
        myButt.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        myButt.setTitleColor(UIColor.magentaColor(), forState: .Normal)
        myButt.addTarget(self, action: #selector(categoryButt(_:)), forControlEvents: .TouchUpInside)
        
        // Add Buttons & Labels based on xCood
        xCoord +=  buttonWidth + gap
        categoriesScrollView.addSubview(myButt)
    } // END LOOP --------------------------
    
    
    // Place Buttons into the ScrollView
    categoriesScrollView.contentSize = CGSizeMake(buttonWidth * CGFloat(itemCount+1), yCoord)
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
    
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = self.newsArray[indexPath.row]
    
    // Get userPointer
    let userPointer = newsClass[NEWS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackgroundWithBlock { (user, error) in
        if error == nil {
            // Show news
            let aUrl = NSURL(string: "\(newsClass[NEWS_URL]!)")
            var domainStr = aUrl!.host
            if domainStr?.rangeOfString("www.") != nil {
                domainStr = domainStr!.stringByReplacingOccurrencesOfString("www.", withString: "")
            }
            cell.newsTitleLabel.text = "\(newsClass[NEWS_TITLE]!) (\(domainStr!))"
            cell.newsTitleLabel.layer.cornerRadius = 8
            cell.votesLabel.text = "\(newsClass[NEWS_VOTES])"
            cell.submittedByOutlet.setTitle("by \(userPointer.username!)", forState: .Normal)
            cell.commentsOutlet.setTitle("\(newsClass[NEWS_COMMENTS])", forState: .Normal)
            cell.categoryOutlet.setTitle("\(newsClass[NEWS_CATEGORY]!)", forState: .Normal)
            let postDate = newsClass.createdAt!
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.postDateLabel.text = dateFormatter.stringFromDate(postDate)
            
            
    
            // Assing tags to the buttons (for later use)
            cell.upVoteOutlet.tag = indexPath.row
            cell.downVoteOutlet.tag = indexPath.row
            cell.submittedByOutlet.tag = indexPath.row
            cell.categoryOutlet.tag = indexPath.row
            cell.commentsOutlet.tag = indexPath.row
            cell.shareOutlet.tag = indexPath.row
            cell.saveOutlet.tag = indexPath.row
            cell.reportOutlet.tag = indexPath.row
        }
    }
    
    
return cell
}
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 144
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW NEWS VIA WEB VIEW
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[indexPath.row]
        let urlStr = "\(newsClass[NEWS_URL]!)"
        
        let mbVC = storyboard?.instantiateViewControllerWithIdentifier("MiniBrowser") as! MiniBrowser
        mbVC.urlString = urlStr
        navigationController?.pushViewController(mbVC, animated: true)
}
    
    
    
    
// MARK: UP-VOTE BUTTON
@IBAction func upVoteButt(sender: AnyObject) {
    // USER IS LOGGED IN
    if PFUser.currentUser() != nil {
            
        let butt = sender as! UIButton
        let indexP = NSIndexPath(forRow: butt.tag, inSection: 0)
        let cell = newsTableView.cellForRowAtIndexPath(indexP) as! NewsCell
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
        //let currentVotes = newsClass[NEWS_VOTES] as! Int
        
        
        // Query Votes
        votesArray.removeAll()
        let query = PFQuery(className: VOTES_CLASS_NAME)
        query.whereKey(VOTES_USER_POINTER, equalTo: PFUser.currentUser()!)
        query.whereKey(VOTES_NEWS_POINTER, equalTo: newsClass)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                self.votesArray = objects!
                print("VOTES ARRAY: \(self.votesArray)")
                
                var votesClass = PFObject(className: VOTES_CLASS_NAME)
                
                if self.votesArray.count > 0 {
                  votesClass = self.votesArray[0]
                  
                    // Get userPointer
                    let userPointer = votesClass[VOTES_USER_POINTER] as! PFUser
                    userPointer.fetchIfNeededInBackgroundWithBlock({ (user, error) in
                        
                        // Get newsPointer
                        let newsPointer = votesClass[VOTES_NEWS_POINTER] as! PFObject
                        newsPointer.fetchIfNeededInBackgroundWithBlock({ (news, error) in
                            // Upvote!
                            if votesClass[VOTES_UPVOTED] == nil  || votesClass[VOTES_UPVOTED] as! Bool == false  {
                                newsClass.incrementKey(NEWS_VOTES)
                                let voteInt = Int(cell.votesLabel.text!)! + 1
                                cell.votesLabel.text = "\(voteInt)"
                                newsClass.saveInBackground()
                                
                                votesClass[VOTES_USER_POINTER] = PFUser.currentUser()
                                votesClass[VOTES_NEWS_POINTER] = newsClass
                                votesClass[VOTES_UPVOTED] = true
                                votesClass[VOTES_DOWNVOTED] = false
                                votesClass.saveInBackground()
                                
                            // Cannot upvote!
                            } else if votesClass[VOTES_UPVOTED] as! Bool == true {
                                self.simpleAlert("You've already upvoted this idea!")
                            }
                        })
                        
                    })
                   
                
                    
                } else {
                    newsClass.incrementKey(NEWS_VOTES)
                    let voteInt = Int(cell.votesLabel.text!)! + 1
                    cell.votesLabel.text = "\(voteInt)"
                    newsClass.saveInBackground()
                    
                    votesClass[VOTES_USER_POINTER] = PFUser.currentUser()
                    votesClass[VOTES_NEWS_POINTER] = newsClass
                    votesClass[VOTES_UPVOTED] = true
                    votesClass[VOTES_DOWNVOTED] = false
                    votesClass.saveInBackground()
                }
                
                
            // Error in query
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}


        
        
        
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to Vote",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    


    
// MARK: DOWN-VOTE BUTTON
@IBAction func downVoteButt(sender: AnyObject) {
    // USER IS LOGGED IN
    if PFUser.currentUser() != nil {
            
            let butt = sender as! UIButton
            let indexP = NSIndexPath(forRow: butt.tag, inSection: 0)
            let cell = newsTableView.cellForRowAtIndexPath(indexP) as! NewsCell
            var newsClass = PFObject(className: NEWS_CLASS_NAME)
            newsClass = newsArray[butt.tag]
            let currentVotes = newsClass[NEWS_VOTES] as! Int

        // Query Votes
        votesArray.removeAll()
        let query = PFQuery(className: VOTES_CLASS_NAME)
        query.whereKey(VOTES_USER_POINTER, equalTo: PFUser.currentUser()!)
        query.whereKey(VOTES_NEWS_POINTER, equalTo: newsClass)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                self.votesArray = objects!
                print("VOTES ARRAY: \(self.votesArray)")
                
                var votesClass = PFObject(className: VOTES_CLASS_NAME)
                
                if self.votesArray.count > 0 {
                    votesClass = self.votesArray[0]
                    
                    let userPointer = votesClass[VOTES_USER_POINTER] as! PFUser
                    userPointer.fetchIfNeededInBackgroundWithBlock({ (user, error) in
                        // Get newsPointer
                        let newsPointer = votesClass[VOTES_NEWS_POINTER] as! PFObject
                        newsPointer.fetchIfNeededInBackgroundWithBlock({ (news, error) in
                            if error == nil {
                                // Downvote!
                                if votesClass[VOTES_DOWNVOTED] == nil  || votesClass[VOTES_DOWNVOTED] as! Bool == false  {
                                    let updatedVotes = currentVotes - 1
                                    newsClass[NEWS_VOTES] = updatedVotes
                                    cell.votesLabel.text = "\(updatedVotes)"
                                    newsClass.saveInBackground()
                                    
                                    votesClass[VOTES_USER_POINTER] = PFUser.currentUser()
                                    votesClass[VOTES_NEWS_POINTER] = newsClass
                                    votesClass[VOTES_DOWNVOTED] = true
                                    votesClass[VOTES_UPVOTED] = false
                                    votesClass.saveInBackground()
                                    
                                // Cannot downvote!
                                } else if votesClass[VOTES_DOWNVOTED] as! Bool == true {
                                    self.simpleAlert("You've already downvoted this idea!")
                                }
                            }
                            
                        })
                        
                    })
                    
                    
                    
                } else {
                    let updatedVotes = currentVotes - 1
                    newsClass[NEWS_VOTES] = updatedVotes
                    cell.votesLabel.text = "\(updatedVotes)"
                    newsClass.saveInBackground()
                    
                    votesClass[VOTES_USER_POINTER] = PFUser.currentUser()
                    votesClass[VOTES_NEWS_POINTER] = newsClass
                    votesClass[VOTES_DOWNVOTED] = true
                    votesClass[VOTES_UPVOTED] = false
                    votesClass.saveInBackground()
                }
                
                
            // Error in query
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}

        

        
        
            
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to Vote",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    

    
    
    
// MARK: - CATEGORY BUTTON
func categoryButt(sender:UIButton) {
    let butt = sender as UIButton
    userID = ""
    searchText = ""
    categoryStr = butt.titleLabel!.text!
    callQueryNews()
    self.title = "\(categoryStr)"
}
    
    
    
    
// MARK: - SUBMITTED BY BUTTON
@IBAction func submittedByButt(sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    let aUser = newsClass[NEWS_USER_POINTER] as? PFUser
    userID = aUser!.objectId!
    categoryStr = ""
    searchText = ""
    callQueryNews()
    
    self.title = "\(aUser!.username!)"
}
    

    
// THE CATEGORY BUTTON IN THE CELL
@IBAction func catsButt(sender: AnyObject) {
   let butt = sender as! UIButton
    userID = ""
    searchText = ""
    categoryStr = butt.titleLabel!.text!
    callQueryNews()
}
    
    
    
// COMMENTS BUTTON
@IBAction func commentsButt(sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    
    let commVC = storyboard?.instantiateViewControllerWithIdentifier("Comments") as! Comments
    commVC.newsObject = newsClass
    navigationController?.pushViewController(commVC, animated: true)
    
}
    
    
    
// MARK: - SHARE BUTTON
@IBAction func shareButt(sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    
    let messageStr  = "\(newsClass[NEWS_TITLE]!) - from #\(APP_NAME)"
    let img = UIImage(named: "h1")!
    
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
    
    
    
    
// MARK: - SAVE NEWS BUTTON
@IBAction func saveButt(sender: AnyObject) {
    let butt = sender as! UIButton
    
    // YOU ARE LOGGED IN
    if PFUser.currentUser() != nil {
        var newsPointer = PFObject(className: NEWS_CLASS_NAME)
        newsPointer = newsArray[butt.tag]
    
        let savedClass = PFObject(className: SAVED_CLASS_NAME)
        let userToSave = newsPointer[NEWS_USER_POINTER] as! PFUser

        // Save data
        savedClass[SAVED_USER_POINTER] = userToSave
        savedClass[SAVED_NEWS_POINTER] = newsPointer
        savedClass[SAVED_SAVING_USER] = PFUser.currentUser()
    
        
        // YOU CAN SAVE NEWS POSTED BY OTHER USERS THAN YOU
        if PFUser.currentUser()!.username != userToSave.username {

          // Saving block
          savedClass.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("You've saved this idea!")
            
            } else {
                let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
           } }
            
            
            
        // CAN'T SAVE YOUR OWN NEWS!
        } else {
            simpleAlert("You can't save your own ideas, just check them out in your Profile!")
        }
        
        
        
    // YOU'RE NOT LOGGED IN
    } else if PFUser.currentUser() == nil {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to save ideas!",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    
    
    
    
    

// MARK: - REPORT INAPPROPRIATE CONTENTS BUTTON
@IBAction func reportButt(sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]

    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
    mailComposer.setSubject("Reporting inappropriate contents on \(APP_NAME)")
    let usernameStr = newsClass[NEWS_USER_POINTER]!.username!
    mailComposer.setMessageBody("Hello<br>I'm reporting a news for inappropriate contents:<br>News Title: <strong>\(newsClass[NEWS_TITLE]!)</strong><br>From author: <strong>\(usernameStr!)</strong><br><br>Please take action against this post.<br>Thanks,<br>Regards.", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
            delegate: nil,
            cancelButtonTitle: "OK")
        alert.show()
    }
}
// Email delegate
func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    var outputMessage = ""
    switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResultSent.rawValue:
            outputMessage = "Thanks for reporting inapprorpiate contents!\nWe'll check it out asap."
        case MFMailComposeResultFailed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
    default: break }
    
    
    simpleAlert(outputMessage)
    dismissViewControllerAnimated(false, completion: nil)
}
    
    
    
    
    
    
    
    
// MARK: - ********  NAVIGATION BAR BUTTONS  ***********
    
//   MARK: - SEARCH BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchViewiSVisible = !searchViewiSVisible
    
    if searchViewiSVisible { showSearchView()
    } else {  hideSearchView()  }
}

// MARK: - SHOW/HIDE SEARCH VIEW
func showSearchView() {
    sortViewIsVisible = false
    hideSortView()
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.searchView.frame.origin.y = 20
        }, completion: { (finished: Bool) in
            self.searchTxt.becomeFirstResponder()
    })
}
func hideSearchView() {
    searchViewiSVisible = false
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.searchView.frame.origin.y = -self.searchView.frame.size.height
    }, completion: { (finished: Bool) in
        self.searchTxt.text = ""
        self.searchTxt.resignFirstResponder()
    })
}
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    categoryStr = ""
    userID = ""
    searchText = searchTxt.text!
    // Call query
    callQueryNews()
    
    hideSearchView()
    
return true
}
    
    
    
// MARK: - USER BUTTON
@IBAction func userButt(sender: AnyObject) {
    if PFUser.currentUser() != nil {
        let accVC = storyboard?.instantiateViewControllerWithIdentifier("Account") as! Account
        navigationController?.pushViewController(accVC, animated: true)
    } else {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
}
    
    
    
    
    
// MARK: - ADD LINK BUTTON
@IBAction func addLinkButt(sender: AnyObject) {
    
    // USER IS LOGGED IN/REGISTERED -> GO TO POST LINK CONTROLLER
    if PFUser.currentUser() != nil {
        categoryStr = ""
        userID = ""
        searchText = ""
        let plVC = storyboard?.instantiateViewControllerWithIdentifier("PostLink") as! PostLink
        navigationController?.pushViewController(plVC, animated: true)
            
            
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to add Links",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Login" {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
}
    
    
    
    
// MARK: - SORT BY BUTTON
@IBAction func sortByButt(sender: AnyObject) {
    sortViewIsVisible = !sortViewIsVisible
    if sortViewIsVisible { showSortView()
    } else { hideSortView()  }
}
    
// MARK: - SHOW/HIDE SORT VIEW
func showSortView() {
    hideSearchView()
    searchViewiSVisible = false
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.sortView.frame.origin.y = 20
    }, completion: { (finished: Bool) in })
}
func hideSortView() {
    sortViewIsVisible = false
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.sortView.frame.origin.y = -self.sortView.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    

// MARK: - SORT BY DATE BUTTON
@IBAction func sortDateButt(sender: AnyObject) {
    sortByVotes = false
    sortByDate = true
    hideSortView()
   
    // Call query
    callQueryNews()
}

    
// MARK: - SORT BY VOTES BUTTON
@IBAction func sortVotesButt(sender: AnyObject) {
    sortByVotes = true
    sortByDate = false
    hideSortView()
    
//    // Query by Category
//    if categoryStr != "" { query.whereKey(NEWS_CATEGORY, equalTo: text)
//    } else { self.title = "Latest" }
    

    
    
    // Call query
    callQueryNews()
}
    

// SHOW LATEST NEWS BUTTON
@IBAction func showLatestNewsButt(sender: AnyObject) {
    sortByVotes = false
    sortByDate = true
    categoryStr = ""
    userID = ""
    searchText = ""
    hideSortView()
    
    callQueryNews()
}
    


    
    
    
// MARK: - ADMOB BANNER METHODS ------------------------
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





