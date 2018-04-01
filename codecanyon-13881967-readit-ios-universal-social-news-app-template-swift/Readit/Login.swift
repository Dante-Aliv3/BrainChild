/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse


class Login: UIViewController,
    UITextFieldDelegate,
    UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    
    @IBOutlet var logoBack: UIImageView!
   
    
    
override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {  dismissViewControllerAnimated(false, completion: nil) }
}
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Setup layouts
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.magentaColor()
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: color])
    
    
    //added by casey
    //blurEffect
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
    logoBack.addSubview(blurEffectView)
    
    
}
    
   
// MARK: - LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
    dismissKeyboard()
    showHUD()
        
    PFUser.logInWithUsernameInBackground(usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        // Login successfull
        if user != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.hideHUD()
                
        // Login failed. Try again or SignUp
        } else {
            let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: self,
                cancelButtonTitle: "Retry",
                otherButtonTitles: "Sign Up")
            alert.show()
            self.hideHUD()
    } }
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
        signupButt(self)
    }
    if alertView.buttonTitleAtIndex(buttonIndex) == "Reset Password" {
        PFUser.requestPasswordResetForEmailInBackground("\(alertView.textFieldAtIndex(0)!.text!)")
        showNotifAlert()
    }
}
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUp") as! SignUp
    presentViewController(signupVC, animated: true, completion: nil)
}
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {  passwordTxt.resignFirstResponder() }
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}

// MARK: - CLOSE BUTTON
@IBAction func closeButt(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
}
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Type your email address you used to register.",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Reset Password")
    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
    alert.show()
}
    
// MARK: - NOTIFICATION ALERT FOR PASSWORD RESET
func showNotifAlert() {
    simpleAlert("You will receive an email shortly with a link to reset your password")
}
    
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
