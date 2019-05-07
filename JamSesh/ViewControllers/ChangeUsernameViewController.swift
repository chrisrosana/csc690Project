//
//  ChangeUsernameViewController.swift
//  JamSesh
//
//  Created by Christopher Rosana on 5/1/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class ChangeUsernameViewController: UIViewController {

    @IBOutlet weak var currentUsernameField: UITextField!
    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var retypeUsernameField: UITextField!
    
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
        if (newUsernameField.text!.isEmpty || retypeUsernameField.text!.isEmpty || currentUsernameField.text!.isEmpty) {
            self.displayMyAlertMessage(title:"All fields are required",message: "Please try again")
        }
        
        // Check if match
        if(currentUsernameField.text == user.username) {
            
            if newUsernameField.text!.isEmpty || retypeUsernameField.text!.isEmpty {
                self.displayMyAlertMessage(title:"All fields are required",message: "Please try again")
                
            } else if (newUsernameField.text == retypeUsernameField.text) {
                    user["username"] = newUsernameField.text
                    user.saveInBackground()
                
                    // Display message successful
                    let myAlert = UIAlertController(title: "Username Change Successful", message: "Thank you!", preferredStyle: UIAlertController.Style.alert)
                
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
                    self.displayMyAlertMessage(title:"Username Do Not Match", message: "Please try again")
                
            }
            
        } else {
            self.displayMyAlertMessage(title:"Username Not Match", message: "This username does not match on this account.")
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
