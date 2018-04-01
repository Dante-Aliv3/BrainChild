/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import Foundation
import UIKit



// REPLACE THE RED STRING BELOW WITH THE NEW NAME YOU'LL GIVE TO THIS APP
let APP_NAME = "Brainchild"


// REPLACE THE RED STRING BELOW WITH THE EMAIL ADDRESS YOU'LL DEDICATE TO REPORTS OF INAPPROPRIATE CONTENTS
let REPORT_EMAIL_ADDRESS = "everdayenergy@yahoo.com"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-5395321550360079/9540017148"


// PARSE KEYS -> REPLACE THEM WITH YOUR OWN ONES FROM YOUR APP ON PARSE.COM -> SETTINGS PABNEL OF YOUR CONSOLE
let PARSE_APP_KEY = "1h0XgZjQ28QePlPj5UX6FB4NcthJ2uCtVkrBNrPK"
let PARSE_CLIENT_KEY = "ppcHGHQrawcRnUA52KVxCK18CZZ27zLn8mexRMtS"

//let PARSE_APP_KEY = "opQ0UXEVcvGZusDvltgk764YEPd27Z32DYApGBE1"
//let PARSE_CLIENT_KEY = "0WLeO626HzQEjp5yPQeefT1zuDqAlyyk0k6ZZqOh"


// HUD VIEW
var hudView = UIView()
var animImage = UIImageView(frame: CGRectMake(0, 0, 142, 142))

extension UIViewController {
    func showHUD() {
        hudView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height-130)
        hudView.backgroundColor = UIColor .clearColor()
        let imagesArr = ["h1", "h2", "h3"]
        var images:[UIImage] = []
        for i in 0..<imagesArr.count {
            images.append(UIImage(named: imagesArr[i])!)
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.3
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        view.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
    
    func simpleAlert(mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}








/******** DO NOT EDIT THE VARIABLES BELOW! ******/
let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"

let CATEGORIES_CLASS_NAME = "Categories"
let CATEGORIES_CATEGORY = "category"

let NEWS_CLASS_NAME = "News"
let NEWS_USER_POINTER = "userPointer"
let NEWS_TITLE = "title"
let NEWS_TITLE_LOWERCASE = "titleLowercase"
let NEWS_VOTES = "votes"
let NEWS_COMMENTS = "comments"
let NEWS_URL = "url"
let NEWS_CATEGORY = "category"

let SAVED_CLASS_NAME = "Saved"
let SAVED_USER_POINTER = "userPointer"
let SAVED_SAVING_USER = "savingUser"
let SAVED_NEWS_POINTER = "newsPointer"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_TEXT = "text"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_NEWS_POINTER = "newsPointer"

let VOTES_CLASS_NAME = "Votes"
let VOTES_USER_POINTER = "userPointer"
let VOTES_NEWS_POINTER = "newsPointer"
let VOTES_UPVOTED = "upvoted"
let VOTES_DOWNVOTED = "downvoted"










