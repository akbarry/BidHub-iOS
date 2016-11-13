//
//  LoginViewController.swift
//  AuctionApp
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    var viewShaker:AFViewShaker?
    override func viewDidLoad() {
        super.viewDidLoad()

        viewShaker = AFViewShaker(viewsArray: [nameTextField, emailTextField])
        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: AnyObject) {
        
        if nameTextField.text != "" && emailTextField.text != "" {
            
            var user = PFUser()
            user["fullname"] = nameTextField.text?.lowercased()
            user.username = emailTextField.text?.lowercased()
            user.password = "test"
            user.email = emailTextField.text?.lowercased()
            
            user.signUpInBackground {
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded == true {
                    self.registerForPush()
                    self.performSegue(withIdentifier: "loginToItemSegue", sender: nil)
                } else {
                    let errorString = error.userInfo!["error"] as! NSString
                    println("Error Signing up: \(error)")
                    PFUser.logInWithUsername(inBackground: user.username, password: user.password, block: { (user, error) -> Void in
                        if error == nil {
                            
                            self.registerForPush()
                            self.performSegue(withIdentifier: "loginToItemSegue", sender: nil)
                        }else{
                            println("Error logging in ")
                            self.viewShaker?.shake()
                        }
                    })
                }
            }
            
        }else{
            //Can't login with nothing set
            viewShaker?.shake()
        }
    }
    
    
    func registerForPush() {
        let user = PFUser.current()
        let currentInstalation = PFInstallation.current()
        currentInstalation?["email"] = user?.email
        currentInstalation?.saveInBackground(nil)

        
        let application = UIApplication.shared
        
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            let types: UIRemoteNotificationType = .Badge | .Alert | .Sound
            application.registerForRemoteNotifications(matching: types)
        }
        
    }
}
