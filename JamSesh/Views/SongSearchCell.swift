//
//  SongSearchCell.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/26/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class SongSearchCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addSongButton: UIButton!
    
    var playlist: PFObject?
    var song: PFObject?
    var inPlaylist = false
    
    @IBAction func addSong(_ sender: Any) {
        if(!inPlaylist) {
            playlist?.add(self.song!, forKey: "songs")
            playlist?.saveInBackground(block: { (success, error) in
                if success {
                    //let filename = self.song!["fileName"] as! String
                    SoundPlayer.sharedInstance.addSong(song: self.song!)
                    self.addSongButton.setImage(UIImage(named: "check"), for: UIControl.State.normal)
                    print("A song was added to the playlist!")
                }
                else {
                    print("Can't add song to your playlist!")
                }
            })
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
