/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse

class SignUp: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    
    //added by casey
    @IBOutlet var logoBack2: UIImageView!

    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Setup layout views
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 300)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.magentaColor()
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: color])
    emailTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: color])
    
    
    
    //added by casey
    //blurEffect
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
    logoBack2.addSubview(blurEffectView)
    
    
    
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
   dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {

    if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" {
        simpleAlert("You must fill all the fields to sign up!")
    } else {
        
        dismissKeyboard()
    	showHUD()

        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text!.lowercaseString
        userForSignUp.password = passwordTxt.text
        userForSignUp.email = emailTxt.text
    
        userForSignUp.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
            // SUCCESSFULL SIGN UP
            if error == nil {
                self.dismissViewControllerAnimated(false, completion: nil)
                self.hideHUD()
        
            // ERROR ON SIGN UP
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    
    }
}
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt    {  emailTxt.resignFirstResponder()     }
return true
}
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    

// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
