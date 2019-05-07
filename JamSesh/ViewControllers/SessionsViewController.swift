//
//  SessionsViewController.swift
//  JamSesh
//
//  Created by Monali Chuatico on 4/10/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class SessionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    
    let currUser = PFUser.current()
    var following = [PFUser]()
    var musicSessions = [PFObject]()
    
    var selectedSession: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        sessionCollectionView.delegate = self
        sessionCollectionView.dataSource = self
        
        //sets the layout of the collection view
        let layout = sessionCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        let width = (view.frame.size.width - layout.minimumInteritemSpacing*3) / 2
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getFollowing()
        loadSessions()
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
    
    func loadSessions() {
        let query = PFQuery(className:"MusicSession")
        query.includeKeys(["admin", "playlist", "playlist.songs"])
        query.addDescendingOrder("createdAt")
        musicSessions.removeAll()
        query.findObjectsInBackground { (sessions, error) in
            if sessions != nil {
                for session in sessions! {
                    let admin = session["admin"] as! PFUser
                    if admin.objectId == self.currUser?.objectId {
                        self.musicSessions.append(session)
                    }
                    else if(!self.following.isEmpty) {
                        for user in self.following {
                            if user.objectId == admin.objectId {
                                self.musicSessions.append(session)
                            }
                        }
                    }
                }
                print("Retrieved Music Sessions")
                self.sessionCollectionView.reloadData()
            }
            else {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicSessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicSessionCell", for: indexPath) as! MusicSessionCell
        let session = musicSessions[indexPath.row]
        cell.musicSessionName.text = session["sessionName"] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSession = musicSessions[indexPath.row]
        performSegue(withIdentifier: "sessionToDetailSegue", sender: nil)
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sessionToDetailSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let detailVC = navVC.viewControllers.first as? DetailsViewController {
                    detailVC.session = selectedSession
                }
            }
        }
     }
 
    
}
