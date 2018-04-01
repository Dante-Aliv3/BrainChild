/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import MessageUI


// MARK: - CUSTOM COMMENT CELL
class CommentCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}









// MARK: - COMMENTS CONTROLLER
class Comments: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate
{

    /* Views */
    @IBOutlet weak var commTableView: UITableView!
    
    @IBOutlet weak var fakeTxt: UITextField!
    var commentView = UIView()
    var commentTxt = UITextField()
    
    
    /* Variables */
    var newsObject = PFObject(className: NEWS_CLASS_NAME)
    var commArray = [PFObject]()
    
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "Comments"
    print("NEWS OBJ: \(newsObject)")

    // Initialize a BACK BarButton Item
    let backbutt = UIButton(type: UIButtonType.Custom)
    backbutt.adjustsImageWhenHighlighted = false
    backbutt.frame = CGRectMake(0, 0, 30, 30)
    backbutt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    backbutt.addTarget(self, action: #selector(backButton), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutt)
    
    
    
    // Input Accessory View for comments initialization --------------------------------
    fakeTxt.delegate = self
    fakeTxt.keyboardAppearance = .Dark
    
    commentView = UIView(frame: CGRectMake(0, view.frame.size.height - 90, view.frame.size.width, 44) )
    commentView.backgroundColor = UIColor .blackColor()
    commentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
    commentTxt = UITextField(frame: CGRectMake(0, 0, commentView.frame.size.width - 20, 32) )
    commentTxt.center = CGPointMake(commentView.frame.size.width/2, commentView.frame.size.height/2)
    commentTxt.delegate = self
    commentTxt.autocapitalizationType = .None
    commentTxt.autoresizingMask = .FlexibleWidth
    commentTxt.borderStyle = .RoundedRect
    commentTxt.backgroundColor = UIColor.whiteColor()
    commentTxt.font = UIFont(name: "HelveticaNeue", size: 16)
    commentTxt.textColor = UIColor.blackColor()
    commentTxt.returnKeyType = .Send
    commentTxt.placeholder = "Post a comment"
    commentTxt.keyboardAppearance = .Dark
    commentView.addSubview(commentTxt)
    
    fakeTxt.inputAccessoryView = commentView
    //-------------------------------------------------------------------------------------

    
    
    // Query all comments of this post
    queryComments()
}
 
    
    
// MARK: - QUERY COMMENTS
func queryComments() {
    commArray.removeAll()
    showHUD()
    
    let query = PFQuery(className: COMMENTS_CLASS_NAME)
    query.whereKey(COMMENTS_NEWS_POINTER, equalTo: newsObject)
    query.includeKey(COMMENTS_USER_POINTER)
    query.orderByDescending("createdAt")
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.commArray = objects!
            self.commTableView.reloadData()
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
    return commArray.count
}
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commCell", forIndexPath: indexPath) as! CommentCell
    
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = commArray[indexPath.row]
    let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
    
    // Get data
    cell.usernameLabel.text = "by \(userPointer[USER_USERNAME]!)"
    cell.commentLabel.text = "\(commClass[COMMENTS_TEXT]!)"
    let postDate = commClass.createdAt!
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    cell.dateLabel.text = dateFormatter.stringFromDate(postDate)
    
    
return cell
}
   
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 90
}
    
    

// MARK: - DELETE AND REPOERT A COMMENT BY SWIPING THE CELL LEFT
func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}
 
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
}

func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = self.commArray[indexPath.row]
    var userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
    do { userPointer = try userPointer.fetchIfNeeded() } catch {}
    
    
    
    // REPORT COMMENT ACTION
    let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Report" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
        mailComposer.setSubject("Reporting inappropriate contents on \(APP_NAME)")
        let usernameStr = commClass[COMMENTS_USER_POINTER]!.username!
        mailComposer.setMessageBody("Hello<br>I'm reporting a comment for inappropriate contents:<br>Comment Text: <strong>\(commClass[COMMENTS_TEXT]!)</strong><br>From: <strong>\(usernameStr!)</strong><br><br>Please take action against this comment.<br>Thanks,<br>Regards.", isHTML: true)
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposer, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: APP_NAME,
                message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        }
    })
    
    
    
        
    // DELETE COMMENT ACTION
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
        
            if PFUser.currentUser()!.username == userPointer.username! {
                commClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                    if error == nil {
                        self.commArray.removeAtIndex(indexPath.row)
                        self.commTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                        
                        // Decrease comments amount
                        self.newsObject.incrementKey(NEWS_COMMENTS, byAmount: -1)
                        self.newsObject.saveInBackground()
                        
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                }}
                
                
            // CURRENT USER CANNOT DELETE OTHER USERS POSTS
            } else {
                self.simpleAlert("You can't delete other users comments")
            }
        })
    
    
        
    // Set colors of the actions
    reportAction.backgroundColor = UIColor.grayColor()
    deleteAction.backgroundColor = UIColor.redColor()
        
    return [reportAction, deleteAction]
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
        outputMessage = "Thanks for reporting inapprorpiate content!\nWe'll check it out asap."
        case MFMailComposeResultFailed.rawValue:
        outputMessage = "Something went wrong with sending Mail, try again later."
    default: break }
    
    
    simpleAlert(outputMessage)
    dismissViewControllerAnimated(false, completion: nil)
}

    
    
    
    
    

// MARK: - POST A COMMENT -> HIT SEND ON KEYBOARD
func textFieldShouldReturn(textField: UITextField) -> Bool {
        
    // USER IS LOGGED IN, CAN POST COMMENTS -----------------------
    if PFUser.currentUser() != nil {
            
        if commentTxt.text != "" {
                showHUD()
                let commClass = PFObject(className: COMMENTS_CLASS_NAME)
                let currentUser = PFUser.currentUser()!
            
                // Save PFUser as Pointer
                commClass[COMMENTS_USER_POINTER] = currentUser
                // Save comment text
                commClass[COMMENTS_TEXT] = commentTxt.text
                // Save postID
                commClass[COMMENTS_NEWS_POINTER] = newsObject
            
            newsObject.incrementKey(NEWS_COMMENTS)
            newsObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    // Saving block
                    commClass.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            // Comment posted, reload commTavleView
                            self.queryComments()
                            self.hideHUD()
                        } else {
                            self.simpleAlert("\(error!.localizedDescription)")
                            self.hideHUD()
                    }}
                }
            })
            
            
        
            
        // In case there's no text in the commentTxt
        } else {
            simpleAlert("You must type something :)")
        }
            
            
            
            
            
        // USER IS NOT LOGGED IN, CAN'T POST COMMENTS ---------------
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to add Links",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
            alert.show()
        }
        
    
        // Reset textFields
        commentTxt.text = ""
        commentTxt.resignFirstResponder()
        fakeTxt.text = ""
        fakeTxt.resignFirstResponder()
        
return true
}
    
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Login" {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
}
    
    
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    fakeTxt.text = ""
    commentTxt.becomeFirstResponder()
        
return  true
}

    
    
// MARK: - BACK BUTTON
func backButton() {
    navigationController?.popViewControllerAnimated(true)
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
