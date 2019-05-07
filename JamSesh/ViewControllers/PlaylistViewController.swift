//
//  PlaylistViewController.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/25/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Parse

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SongCellUpdater {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var playAllButton: UIButton!
    
    var playlist: PFObject?
    var songs = [PFObject]()
    var filenames = [String]()
    
    var song: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        playlistNameLabel.text = playlist?["playlistName"] as? String
        songs = playlist?["songs"] as? [PFObject] ?? []
        self.filenames = self.getFilenames()
        
        if !SoundPlayer.sharedInstance.isPlaying {
            SoundPlayer.sharedInstance.playlistId = (self.playlist?.objectId!)!
            addSongs()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        songs = playlist?["songs"] as? [PFObject] ?? []
        self.filenames = self.getFilenames()
        tableView.reloadData()
        
        if playlist?.objectId == SoundPlayer.sharedInstance.playlistId {
            if SoundPlayer.sharedInstance.isPlaylistPlaying {
                playAllButton.setImage(UIImage(named: "pause-1"), for: UIControl.State.normal)
            }
            else {
                playAllButton.setImage(UIImage(named: "play-1"), for: UIControl.State.normal)
            }
        }
    }
    
    func getFilenames()-> [String]{
        var fileNames = [String]()
        for song in self.songs {
            let filename = song["fileName"] as! String
            fileNames.append(filename)
        }
        
        return fileNames
        
    }
    
    func addSongs() {
        SoundPlayer.sharedInstance.clearPlayer()
        if !songs.isEmpty {
            for song in songs {
                SoundPlayer.sharedInstance.addSong(song: song)
            }
            addSongObserver()
            SoundPlayer.sharedInstance.setSongItem(filename: filenames[0])
        }
    }
    
    func addSongObserver(){
        for song in songs {
            let filename = song["fileName"] as! String
            let playerItem = SoundPlayer.sharedInstance.getSongItem(filename: filename)
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        song = SoundPlayer.sharedInstance.nextSong()
        print("Next Song")
        tableView.reloadData()
    }
    
    @IBAction func onPlayAllButton(_ sender: Any) {
        if playlist?.objectId != SoundPlayer.sharedInstance.playlistId {
            addSongs()
            SoundPlayer.sharedInstance.playlistId = (self.playlist?.objectId!)!
        }
        if !songs.isEmpty {
            if SoundPlayer.sharedInstance.isPlaying {
                playAllButton.setImage(UIImage(named: "play-1"), for: UIControl.State.normal)
                SoundPlayer.sharedInstance.pauseSong()
            }
            else {
                playAllButton.setImage(UIImage(named: "pause-1"), for: UIControl.State.normal)
                SoundPlayer.sharedInstance.playSong()
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func onForwardButton(_ sender: UIButton) {
        song = SoundPlayer.sharedInstance.nextSong()
        tableView.reloadData()
    }
    
    @IBAction func onPreviousButton(_ sender: Any) {
        song = SoundPlayer.sharedInstance.prevSong()
        tableView.reloadData()
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        cell.delegate = self
        let song = songs[indexPath.row]
        cell.song = song
        
        let songTitle = song["songTitle"] as? String
        let artist = song["Artist"] as? String
        cell.songTitleLabel.text = songTitle
        cell.artistLabel.text = artist
        
        if playlist?.objectId == SoundPlayer.sharedInstance.playlistId {
            let filename = song["fileName"] as? String
            let playerItem = SoundPlayer.sharedInstance.getSongItem(filename: filename!)
            
            if SoundPlayer.sharedInstance.player.currentItem == playerItem {
                if SoundPlayer.sharedInstance.isPlaying {
                    cell.playButton.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
                }
                else {
                    cell.playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
                    playAllButton.setImage(UIImage(named: "play-1"), for: UIControl.State.normal)
                }
            }
            else {
                cell.playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            playlist?.remove(songs[indexPath.row], forKey: "songs")
            playlist?.saveInBackground(block: { (success, error) in
                if success {
                    //remove song from queueplayer and filename
                    let filename = self.filenames[indexPath.row]
                    let playerItem = SoundPlayer.sharedInstance.getSongItem(filename: filename)
                    if SoundPlayer.sharedInstance.player.currentItem == playerItem {
                        self.song = SoundPlayer.sharedInstance.nextSong()
                    }
                    SoundPlayer.sharedInstance.removeSong(filename: filename, index: indexPath.row)
                    
                    self.filenames.remove(at: indexPath.row)
                    self.songs.remove(at: indexPath.row)
                    
                    //delete row
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("The song was successfully deleted from playlist")
                }
                else {
                    print("Error encountered in deleting song from playlist")
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let addSongsViewController = segue.destination as! AddSongsViewController
        
        // Pass the selected object to the new view controller.
        addSongsViewController.playlist = playlist
    }
    
}
