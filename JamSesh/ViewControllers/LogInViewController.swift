//
//  LogInViewController.swift
//  JamSesh
//
//  Created by Monali Chuatico on 4/10/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    static var audioPlayer = AVAudioPlayer()
    static var audioIsPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(error!.localizedDescription)")
                self.displayMyAlertMessage(title: error!.localizedDescription, message: "Please try again")
            }
        }
        
        UserDefaults.standard.set(false, forKey: "Play")
        UserDefaults.standard.set(" ", forKey: "Artist")
        UserDefaults.standard.set(" ", forKey: "SongTitle")
    }
    
    // Display message for confirmation
    func displayMyAlertMessage(title:String, message: String) {
        
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
