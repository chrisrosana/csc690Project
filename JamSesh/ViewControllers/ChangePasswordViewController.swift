//
//  ChangePasswordViewController.swift
//  JamSesh
//
//  Created by Christopher Rosana on 5/1/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func endTyping(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onChange(_ sender: Any) {
        
        let user = PFUser.current()!
        
        // Check for empty fields
        if (newPasswordTextField.text!.isEmpty || retypePasswordTextField.text!.isEmpty || emailTextField.text!.isEmpty) {
            self.displayMyAlertMessage(title:"All fields are required",message: "Please try again")
        }
        
        // Check if email match
        if(emailTextField.text == user.email) {
            // Check if new password match
            if newPasswordTextField.text!.isEmpty || retypePasswordTextField.text!.isEmpty {
                self.displayMyAlertMessage(title:"All fields are required",message: "Please try again")
                
            } else if (newPasswordTextField.text == retypePasswordTextField.text) {
                    user["password"] = newPasswordTextField.text
                    user.saveInBackground()
                
                    // Display message successful
                    let myAlert = UIAlertController(title: "Password Change Successful", message: "Thank you!", preferredStyle: UIAlertController.Style.alert)
                
                    let okAction = UIAlertAction(title:"Ok", style:UIAlertAction.Style.default){ action in
                        self.dismiss(animated: true, completion:nil);
                    }
                
                    myAlert.addAction(okAction);
                    self.present(myAlert, animated:true, completion:nil);
                
                    // log out
                    PFUser.logOut()
                
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = main.instantiateViewController(withIdentifier: "LogInViewController")
                
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                
                    delegate.window?.rootViewController = loginViewController
                
            } else {
                self.displayMyAlertMessage(title:"Password Do Not Match", message: "Please try again")
                
            }
        } else {
            self.displayMyAlertMessage(title:"E-mail Not Match", message: "This e-mail does not match on this account.")
        }
        
    }
    
    // Display message for confirmation
    func displayMyAlertMessage(title:String, message:String) {
        
        let myAlert = UIAlertController(title:title, message:message, preferredStyle: UIAlertController.Style.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertAction.Style.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
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
