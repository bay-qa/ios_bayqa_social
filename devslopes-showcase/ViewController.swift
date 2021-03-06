import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase


class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
        
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged In! \(user?.email)")
                        
//                        //Store what type of account this is
//                        let userData = ["provider": credential.provider]
//                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
//                        
                       NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                       self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }

                })
            }
            
        }
    }
    
    
    @IBAction func attemptLogin(sender: UIButton!) {
        //Make sure there is an email and a password
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {

            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
            if error != nil {
                    print(error)
                
                   //checks if account does not exists
                    if error!.code == STATUS_ACCOUNT_NOEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                                                            if error != nil {
                                                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                                                            } else {
//                                                                let uid = user[KEY_UID] as? String
                                                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                                                
                                                                
                                                                    //Store what type of account this is
                                                                let userData = ["provider" : "email"]
                                                                    DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                                                    
                                                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                                            }
                        })
                    } else {
                        self.showErrorAlert("Error loggin in", msg: "Could not log in. Check your username and password")
                    }
                    
                } else {
                    self.performSegueWithIdentifier("loggedIn", sender: nil)
                }
            })
        }else {
            showErrorAlert("Email and Password Required", msg: "You must provide email and password!")
        }
    
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    

}

