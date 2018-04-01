/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse


class PostLink: UIViewController,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var urlTxt: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    /* Variables */
    var categoriesArray = [PFObject]()
    var categoryStr = ""
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    self.title = "My Idea"
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 600)
    categoryStr = ""
    
    
    // Set placeholders layout
    let color = UIColor.blackColor()
    titleTxt.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSForegroundColorAttributeName: color])
    urlTxt.attributedPlaceholder = NSAttributedString(string: "Paste URL link with http:// prefix", attributes: [NSForegroundColorAttributeName: color])

    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: UIButtonType.Custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRectMake(0, 0, 30, 30)
    butt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    butt.addTarget(self, action: #selector(backButt(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Call query
    queryCategories()
}


// MARK: - QUERY CATEGORIES
func queryCategories() {
    categoriesArray.removeAll()
    
    showHUD()
        
    let query = PFQuery(className: CATEGORIES_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                self.categoriesArray = objects!
                self.showCategories()
                
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
    }}
}
    
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
    categoriesScrollView.contentSize = CGSizeMake(buttonWidth * CGFloat(itemCount+2), yCoord)
}
    
    
    
// MARK: - CATEGORY BUTTON
func categoryButt(sender:UIButton) {
    let butt = sender as UIButton
    categoryStr = butt.titleLabel!.text!
    categoryLabel.text = categoryStr
}
    
    
    
    
// MARK: - POST LINK BUTTON
@IBAction func postLinkButt(sender: AnyObject) {
    showHUD()
    titleTxt.resignFirstResponder()
    urlTxt.resignFirstResponder()
    
    let newsClass = PFObject(className: NEWS_CLASS_NAME)
    let currentUser = PFUser.currentUser()!
    
    newsClass[NEWS_TITLE] = titleTxt.text
    newsClass[NEWS_TITLE_LOWERCASE] = titleTxt.text!.lowercaseString
    newsClass[NEWS_USER_POINTER] = currentUser
    newsClass[NEWS_URL] = urlTxt.text
    newsClass[NEWS_CATEGORY] = categoryStr
    newsClass[NEWS_COMMENTS] = 0
    newsClass[NEWS_VOTES] = 0
    
    
    // CAN POST LINK
    if titleTxt.text != ""  &&  urlTxt.text!.hasPrefix("http://")   && categoryStr != "" {
      newsClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            self.categoryStr = ""
            self.hideHUD()
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
        
        
    // CANNOT POST YOUR LINK -> MISSING INFO
    } else {
        self.simpleAlert("You must insert a Title, a URL with 'http://' as prefix, and choose a Category")
        hideHUD()
    }
}
    
    
    

// MARK: - TEXT FIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == titleTxt  { urlTxt.becomeFirstResponder() }
    if textField == urlTxt    { urlTxt.resignFirstResponder() }
    
return true
}

    
// MARK: - BACK BUTTON
func backButt(sender:UIButton) {
    navigationController?.popViewControllerAnimated(true)
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
