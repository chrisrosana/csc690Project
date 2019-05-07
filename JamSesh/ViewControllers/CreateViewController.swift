//
//  CreateViewController.swift
//  JamSesh
//
//  Created by Monali Chuatico on 4/10/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class CreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var privateBool: UISwitch!
    @IBOutlet weak var selectPlaylistButton: UIButton!
    @IBOutlet weak var playlistTableView: UITableView!
    
    var currUser = PFUser.current()!
    var playlists = [PFObject]()
    
    var selectedPlaylist: PFObject?
    var createdSession: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up table
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        playlistTableView.isHidden = true
        
        //set up textfield
        titleField.delegate = self
        
        //get playlist
        loadPlaylists();
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        let currPlaylist = playlists[indexPath.row]
        cell.textLabel?.text = currPlaylist["playlistName"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currPlaylist = playlists[indexPath.row]
        let title = currPlaylist["playlistName"] as? String
        selectedPlaylist = currPlaylist
        selectPlaylistButton.setTitle(title, for: .normal)
    }
    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
        
        if(titleField.text == "" || selectPlaylistButton.titleLabel?.text == "Select Playlist"){
            //creating an alert box
            let alert = UIAlertController(title: "Empty Fields!", message: "Please fill out all the fields to continue!", preferredStyle: .alert)
            
            let okayButton = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            alert.addAction(okayButton)
            self.present(alert, animated: true, completion:  nil)
        }
        else
        {
            let session = PFObject(className: "MusicSession")
            session["sessionName"] = titleField.text
            session["admin"] = currUser
            session["playlist"] = selectedPlaylist
            session["private"] = privateBool.isOn
            
            session.saveInBackground { (success, error) in
                if(success)
                {
                    self.createdSession = session
                    print("success")
                    self.performSegue(withIdentifier: "createToDetailSegue", sender: nil)
                }
                else
                {
                    print("Error: \(error?.localizedDescription)")
                }
                
            }
        }
    }
    
    @IBAction func selectPlaylistButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if(self.playlistTableView.isHidden) {
                self.playlistTableView.isHidden = false;
            }
            else
            {
                self.playlistTableView.isHidden = true
            }
        }
    }
    
    func loadPlaylists() {
        let query = PFQuery(className:"Playlists")
        query.includeKey("songs")
        query.addDescendingOrder("createdAt")
        playlists.removeAll()
        query.findObjectsInBackground { (playlists, error) in
            if playlists != nil {
                for playlist in playlists! {
                    let author = playlist["author"] as! PFUser
                    if (author.objectId! == self.currUser.objectId) {
                        self.playlists.append(playlist)
                    }
                }
                print("Retrieved user playlists")
                self.playlistTableView.reloadData()
            }
            else {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    //Hide keyboard when user hit return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createToDetailSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let detailVC = navVC.viewControllers.first as? DetailsViewController {
                    detailVC.session = createdSession
                }
            }
        }
    }
    
    
}
