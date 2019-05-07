//
//  SongCell.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/26/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

protocol SongCellUpdater: class {
    func updateTableView()
}

class SongCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var song: PFObject?
    weak var delegate: SongCellUpdater?
    
    func callUpdate() {
        delegate?.updateTableView()
    }
    
    @IBAction func play(_ sender: Any) {
        let songFilename = song?["fileName"] as? String
        
        SoundPlayer.sharedInstance.setSongItem(filename: songFilename!)
        
        if SoundPlayer.sharedInstance.isPlaying {
            playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
            SoundPlayer.sharedInstance.pauseSong()
        }
        else {
            playButton.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
            SoundPlayer.sharedInstance.playSong()
        }
        callUpdate()
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
