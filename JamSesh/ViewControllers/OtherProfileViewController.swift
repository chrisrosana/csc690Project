//
//  OtherProfileViewController.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/20/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class OtherProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followButton: UIButton!
    
    let currUser = PFUser.current()
    var followed = false
    
    var user: PFUser?
    var userInfo: PFObject?
    var currUserInfo: PFObject?
    var userPlaylists = [PFObject]()
    var userFollowers = [PFUser]()
    var userFollowings = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadPlaylists()
        
        //sets the layout of the collection view
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        let width = (view.frame.size.width - layout.minimumInteritemSpacing*3) / 2
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadUserInfo()
    }
    
    func loadUserInfo() {
        usernameLabel.text = user?.username
        
        userFollowers.removeAll()
        userFollowings.removeAll()
        
        let query = PFQuery(className: "UserInfo")
        query.includeKey("user")
        query.findObjectsInBackground { (usersInfo, error) in
            if usersInfo != nil {
                for userInfo in usersInfo! {
                    let user = userInfo["user"] as! PFUser
                    if user.objectId == self.user!.objectId {
                        self.userInfo = userInfo
                        if userInfo["followers"] != nil {
                            self.userFollowers = userInfo["followers"] as! [PFUser]
                        }
                        if userInfo["following"] != nil {
                            self.userFollowings = userInfo["following"] as! [PFUser]
                        }
                        let followersCount = userInfo["followersCount"] as? Int ?? 0
                        let followingCount = userInfo["followingCount"] as? Int ?? 0
                        
                        for follower in self.userFollowers {
                            if follower.objectId == self.currUser?.objectId {
                                self.followed = true
                                self.followButton.setTitle("Unfollow", for: .normal)
                                break
                            }
                        }
                        
                        self.followersCountLabel.text = "\(String(followersCount)) followers"
                        self.followingCountLabel.text = "\(String(followingCount)) following"
                    }
                    else if user.objectId == PFUser.current()?.objectId {
                        self.currUserInfo = userInfo
                    }
                }
            }
        }
        
        
        
        //loads the profile image of user
        let imageFile = user!["image"] as? PFFileObject ?? nil
        if imageFile != nil {
            let urlString = imageFile!.url!
            let url = URL(string: urlString)!
            profileImage.af_setImage(withURL: url)
        }
    }
    
    func loadPlaylists() {
        let query = PFQuery(className:"Playlists")
        query.includeKey("author")
        query.addDescendingOrder("createdAt")
        userPlaylists.removeAll()
        query.findObjectsInBackground { (playlists, error) in
            if playlists != nil {
                for playlist in playlists! {
                    let author = playlist["author"] as! PFUser
                    if (author.objectId! == self.user!.objectId) {
                        self.userPlaylists.append(playlist)
                    }
                }
                print("Retrieved user playlists")
                self.collectionView.reloadData()
            }
            else {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func onFollowButton(_ sender: Any) {
        let userFollowersCount = userInfo?["followersCount"] as? Int ?? 0
        let currUserFollowingCount = currUserInfo?["followingCount"] as? Int ?? 0
        
        if !followed{
            userInfo?.add(PFUser.current()!, forKey: "followers")
            userInfo?["followersCount"] = userFollowersCount + 1
            
            
            currUserInfo?.add(user!, forKey: "following")
            currUserInfo?["followingCount"] = currUserFollowingCount + 1
            
            userInfo?.saveInBackground { (success, error) in
                if success {
                    self.followed = true
                    self.followButton.setTitle("Unfollow", for: .normal)
                    print("followed!")
                }
                else {
                    print("error!")
                }
            }
            
            currUserInfo?.saveInBackground { (success, error) in
                if success {
                    self.followed = true
                    self.followButton.setTitle("Unfollow", for: .normal)
                    print("followed!")
                }
                else {
                    print("error!")
                }
            }
        }
        else {
            userInfo?.remove(PFUser.current()!, forKey: "followers")
            userInfo?["followersCount"] = userFollowersCount - 1
            
            
            currUserInfo?.remove(user!, forKey: "following")
            currUserInfo?["followingCount"] = currUserFollowingCount - 1
            
            userInfo?.saveInBackground { (success, error) in
                if success {
                    self.followed = false
                    self.followButton.setTitle("Follow", for: .normal)
                    print("ufollowed!")
                }
                else {
                    print("error!")
                }
            }
            
            currUserInfo?.saveInBackground { (success, error) in
                if success {
                    self.followed = false
                    self.followButton.setTitle("Follow", for: .normal)
                    print("unfollowed!")
                }
                else {
                    print("error!")
                }
            }
        }
        loadUserInfo()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPlaylists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherPlaylistCell", for: indexPath) as! OtherPlaylistCell
        let playlist = userPlaylists[indexPath.row]
        cell.playlistLabel.text = playlist["playlistName"] as? String
        
        return cell
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
