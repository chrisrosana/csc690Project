//
//  SignUpViewController.swift
//  JamSesh
//
//  Created by Monali Chuatico on 4/10/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser();
        user.username = usernameField.text!
        user.email = emailField.text!
        
        // Gives deafult profile image to user
        let image = UIImage(named: "perm_identity_24px_outlined-2")
        let imageData = image!.pngData()
        let file = PFFileObject(data: imageData!)
        user["image"] = file
        
        // Check if passwords match
        if(passwordField.text == password2Field.text){
            user.password = passwordField.text!
        } else {
            self.displayMyAlertMessage(title:"Password do not match", message: "Please try again")
        }
        
        user.signUpInBackground { (success, error) in
            if success {
                
                // Display message successful
                let myAlert = UIAlertController(title: "Registration successful", message: "Thank you!", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title:"Ok", style:UIAlertAction.Style.default){ action in
                    self.dismiss(animated: true, completion:nil);
                }
                
                myAlert.addAction(okAction);
                self.present(myAlert, animated:true, completion:nil);
                
                
                // User logs in to save user in userinfo
                PFUser.logInWithUsername(inBackground: self.usernameField.text!, password: self.passwordField.text!) { (user, error) in
                    if user != nil {
                        let userInfo = PFObject(className: "UserInfo")
                        userInfo["user"] = user
                        
                        userInfo.saveInBackground { (success, error) in
                            if success {
                                print("saved user info!")
                                //self.performSegue(withIdentifier: "autoLoginSegue", sender: nil)
                            }
                            else {
                                print("error: \(error)")
                            }
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                        self.displayMyAlertMessage(title: error!.localizedDescription, message: "Please try again")
                    }
                }
                PFUser.logOut()
                
                // Go back to login
                //self.performSegue(withIdentifier: "backToLoginSegue", sender: nil)
                
                
            } else {
                print("Error: \(error?.localizedDescription)")
            }
            
        }
        
        // Check for empty fields
        if (usernameField.text!.isEmpty || emailField.text!.isEmpty || passwordField.text!.isEmpty) {
            self.displayMyAlertMessage(title:"All fields are required",message: "Please try again")
        }
        
        
    }
    
    // Display message for confirmation
    func displayMyAlertMessage(title:String, message:String) {
        
        let myAlert = UIAlertController(title:title, message:message, preferredStyle: UIAlertController.Style.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertAction.Style.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
    
    @IBAction func endEditing(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
