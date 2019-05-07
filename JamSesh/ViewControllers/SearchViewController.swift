//
//  SearchViewController.swift
//  JamSesh
//
//  Created by Monali Chuatico on 4/10/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchControl: UISegmentedControl!
    
    var currUser = PFUser.current()
    var users = [PFObject]()
    var filteredUsers = [PFObject]()
    var sessions = [PFObject]()
    var filteredSessions = [PFObject]()
    var following = [PFUser]()
    var searchBarBeginEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        loadUsers()
        filteredUsers = users
        
        getFollowing()
        
        loadSessions()
        filteredSessions = sessions
    }
    
    func loadUsers() {
        let query = PFUser.query()
        query!.findObjectsInBackground { (users, error) in
            if users != nil {
                for user in users! {
                    if user.objectId != PFUser.current()?.objectId {
                        self.users.append(user)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func loadSessions() {
        let query = PFQuery(className: "MusicSession")
        query.includeKeys(["admin", "playlist", "playlist.songs"])
        sessions.removeAll()
        filteredSessions.removeAll()
        query.findObjectsInBackground { (sessions, error) in
            if sessions != nil {
                for session in sessions! {
                    let admin = session["admin"] as! PFUser
                    let isPrivate = session["private"] as! Bool
                    if admin.objectId == self.currUser!.objectId {
                        self.sessions.append(session)
                    }
                    else if(!self.following.isEmpty) {
                        for user in self.following {
                            if user.objectId == admin.objectId {
                                self.sessions.append(session)
                            }
                        }
                    }
                    else if(!isPrivate) {
                        self.sessions.append(session)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getFollowing() {
        let query = PFQuery(className: "UserInfo")
        query.includeKey("user")
        following.removeAll()
        query.findObjectsInBackground { (usersInfo, error) in
            if usersInfo != nil {
                for userInfo in usersInfo! {
                    let user = userInfo["user"] as! PFUser
                    if user.objectId == self.currUser!.objectId {
                        self.following = userInfo["following"] as? [PFUser] ?? []
                        break
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarBeginEditing {
            if searchControl.selectedSegmentIndex == 0 {
                return filteredUsers.count
            }
            else {
                return filteredSessions.count
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        if searchControl.selectedSegmentIndex == 0 {
            let user = filteredUsers[indexPath.row]
            cell.resultLabel.text = user["username"] as? String
            
            let imageFile = user["image"] as? PFFileObject ?? nil
            if imageFile != nil {
                let urlString = imageFile!.url!
                let url = URL(string: urlString)!
                cell.resultImage.af_setImage(withURL: url)
                cell.resultImage.layer.cornerRadius = cell.resultImage.frame.width/2
            }
        }
        else {
            let session = filteredSessions[indexPath.row]
            cell.resultLabel.text = session["sessionName"] as? String
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchControl.selectedSegmentIndex == 0 {
            filteredUsers = users.filter({ (user) -> Bool in
                let username = user["username"] as! String
                return username.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        }
        else {
            filteredSessions = sessions.filter({ (session) -> Bool in
                let sessionName = session["sessionName"] as! String
                return sessionName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarBeginEditing = false
        searchBar.showsCancelButton = false
        searchControl.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.isHidden = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarBeginEditing = true
        searchBar.showsCancelButton = true
        searchControl.isHidden = false
        tableView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchControl.isHidden = false
        tableView.isHidden = false
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch searchControl.selectedSegmentIndex {
        case 0:
            filteredSessions.removeAll()
        case 1:
            filteredUsers.removeAll()
        default:
            break
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchControl.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "searchToProfileSegue", sender: indexPath)
            
        }
        else {
            performSegue(withIdentifier: "searchToSessionSegue", sender: indexPath)
        }
    }
    
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = sender as? IndexPath
        if segue.identifier == "searchToProfileSegue" {
            // Get the new view controller using segue.destination.
            if let profileVC = segue.destination as? OtherProfileViewController {
                // Pass the selected user to the new view controller.
                let user = filteredUsers[indexPath!.row] as! PFUser
                profileVC.user = user
            }
        }
        else {
            // Get the new view controller using segue.destination.
            if let navVC = segue.destination as? UINavigationController {
                if let detailVC = navVC.viewControllers.first as? DetailsViewController {
                    // Pass the selected session to the new view controller.
                    let session = filteredSessions[indexPath!.row]
                    detailVC.session = session
                }
            }
        }
        tableView.deselectRow(at: indexPath!, animated: true)
     }
    
}
