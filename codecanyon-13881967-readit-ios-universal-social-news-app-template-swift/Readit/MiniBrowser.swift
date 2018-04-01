/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import GoogleMobileAds
import AudioToolbox


class MiniBrowser: UIViewController,
UIWebViewDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var webView: UIWebView!
    
    
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var urlString = ""
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    // Sert Title
    self.title = "Loading..."
    
    // Load website
    showHUD()
    let url = NSURL(string: urlString)
    webView.loadRequest(NSURLRequest(URL: url!))
    
    // CONSOLE LOGS:
    print("URL STRING: \(urlString)")

    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: UIButtonType.Custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRectMake(0, 0, 30, 30)
    butt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    butt.addTarget(self, action: #selector(backButt(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
  
    
    
    
    // Init ad banners
    initAdMobBanner()
    
}


    
// MARK: - WEBVIEW DELEGATE TO GET THE ARTICLE'S TITLE
func webViewDidFinishLoad(webView: UIWebView) {
    hideHUD()
    self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
}
    
    
    
    
    
// MARK: - TOOLBAR BUTTONS
@IBAction func toolbarButtons(sender: AnyObject) {
    let butt = sender as! UIBarButtonItem
    
    switch butt.tag {
    
    // Go back
    case 0:
        webView.goBack()
    
    // Go next
    case 1:
        webView.goForward()
    
    // Refresh page
    case 2:
        webView.reload()
        
    // Share page
    case 3:
        let messageStr  = "Check this out: \(urlString) - from #\(APP_NAME)"
        let img = UIImage(named: "logo")
        let shareItems = [messageStr, img!]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypePostToVimeo]
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // iPad
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.presentPopoverFromRect(CGRectZero, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(), animated: true)
        } else {
            // iPhone
            presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        
    default:break }
    
}
    
    

    
    
// MARK: - BACK BUTTON
func backButt(sender: UIButton) {
    navigationController?.popViewControllerAnimated(true)
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
        banner.frame = CGRectMake(0, self.view.frame.size.height - banner.frame.size.height - 44,
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
