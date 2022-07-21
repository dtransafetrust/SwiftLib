//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit
import GoogleSignIn // TrustIssuerNotUse


@UIApplicationMain
class AppDelegate: UIResponder, UIKit.UIApplicationDelegate {
    var window: UIWindow?
    var activationUrl : String = ""
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        try! SWDK.sharedInstance().sessionManager().applicationLaunching(launchOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if(url.scheme == "sampleapp") { // TrustIssuerNotUse
            let appDelegate = UIApplication.shared.delegate as! AppDelegate // TrustIssuerNotUse
            appDelegate.activationUrl = String(describing: url) // TrustIssuerNotUse
            let sb = UIStoryboard(name: "Main", bundle: .main) // TrustIssuerNotUse
            let intance = sb.instantiateViewController(withIdentifier: "root_navigation_bar") as? RootNavigationViewController // TrustIssuerNotUse
            window?.rootViewController = intance // TrustIssuerNotUse
            intance?.visibleViewController?.performSegue(withIdentifier: "active_account_url", sender:nil) // TrustIssuerNotUse
            return true
        } // TrustIssuerNotUse
        return GIDSignIn.sharedInstance().handle(url) // TrustIssuerNotUse
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if(SWDKGlobalData.simulateCrashingInBG) {
            fatalError()
        }
        try! SWDK.sharedInstance().sessionManager().applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        try! SWDK.sharedInstance().sessionManager().applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try! SWDK.sharedInstance().sessionManager().applicationWillTerminate()
    }
}

