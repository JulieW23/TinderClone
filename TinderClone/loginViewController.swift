//
//  loginViewController.swift
//  TinderClone
//
//  Created by Julie Wang on 27/7/2018.
//  Copyright © 2018 Julie Wang. All rights reserved.
//

import UIKit
import Parse

class loginViewController: UIViewController {

    var signupActive = true
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginSignupButton: UIButton!
    @IBOutlet weak var loginSignupSwitchButton: UIButton!
    @IBOutlet weak var loginSingupSwitchLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    func signup() {
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.signUpInBackground { (success, error) in
            if error != nil {
                var errorMessage = "Signup failed - try again"
                if let newError = error as NSError? {
                    if let detailError = newError.userInfo["error"] as? String {
                        errorMessage = detailError
                    }
                }
                self.errorLabel.isHidden = false
                self.errorLabel.text = errorMessage
            } else {
                print("Signup sucessful")
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
            }
        }
    }
    
    func login() {
        if let username = usernameTextField.text, let password = passwordTextField.text {
            PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
                if error != nil {
                    var errorMessage = "Login failed - try again"
                    if let newError = error as NSError? {
                        if let detailError = newError.userInfo["error"] as? String {
                            errorMessage = detailError
                        }
                    }
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                } else {
                    print("Login sucessful")
                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "updateSegue", sender: nil)
        }
    }
    
    @IBAction func loginSignup(_ sender: Any) {
        errorLabel.isHidden = true
        if signupActive {
            signup()
        } else {
            login()
        }
    }
    
    @IBAction func switchLoginSignup(_ sender: Any) {
        signupActive = !signupActive
        if signupActive {
            loginSignupButton.setTitle("Sign Up", for: [])
            loginSignupSwitchButton.setTitle("Log In", for: [])
            loginSingupSwitchLabel.text = "Already have an account?"
        } else {
            loginSignupButton.setTitle("Log In", for: [])
            loginSignupSwitchButton.setTitle("Sign Up", for: [])
            loginSingupSwitchLabel.text = "Don't have an account?"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        errorLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
