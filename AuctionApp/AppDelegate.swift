
//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("<your app id>", clientKey: "<your client key>")
        PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions, block: nil)
        

        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        
        let currentUser = PFUser.current()
        if currentUser != nil {
            let itemVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController
            window?.rootViewController=itemVC
        } else {
            //Prompt User to Login
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window?.rootViewController=loginVC
        }
        
        UITextField.appearance().tintColor = UIColor.orange

    
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 177/255, green: 23/255, blue: 50/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UISearchBar.appearance().barTintColor = UIColor(red: 177/255, green: 23/255, blue: 50/255, alpha: 1.0)
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstalation = PFInstallation.current()
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        println("tokenString: \(tokenString)")
        
        currentInstalation?.setDeviceTokenFrom(deviceToken)
        currentInstalation?.saveInBackground(nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "pushRecieved"), object: userInfo)
//        println("Push! \(userInfo)")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
}



