//
//  SoundPlayer.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/29/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import AVFoundation
import Parse


class SoundPlayer {
    
    // Singleton in order to access the player from 'everywhere'
    class var sharedInstance : SoundPlayer {
        struct Static {
            static let instance : SoundPlayer = SoundPlayer()
        }
        return Static.instance
    }
    
    // Properties
    var player = AVPlayer()
    var isPlaying = false
    var isPlaylistPlaying = false
    var currItem: AVPlayerItem?
    var playlistId = String()
    var time = CMTime.zero
    var songs = [PFObject]()
    var filenames = [String]()
    var playerItems = [String:AVPlayerItem]()
    
    init() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }
        }
        catch {
            print(error)
        }
    }
    
    func addSong(song: PFObject) {
        let fileName = song["fileName"] as! String
        let playerItem = AVPlayerItem(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "mp3")!))
        songs.append(song)
        playerItems[fileName] = playerItem
        filenames.append(fileName)
    }
    
    func removeSong(filename: String, index: Int) {
        let playerItem = playerItems[filename] as! AVPlayerItem
        songs.remove(at: index)
        playerItems.removeValue(forKey: filename)
        filenames.remove(at: index)
    }
    
    func setSongItem(filename: String) {
        let playerItem = playerItems[filename] as! AVPlayerItem
        player.replaceCurrentItem(with: playerItem)
    }
    
    func getSongItem(filename: String) -> AVPlayerItem {
        let playerItem = playerItems[filename] as! AVPlayerItem
        return playerItem
    }
    
    func clearPlayer(){
        player.pause()
        songs.removeAll()
        playerItems.removeAll()
        filenames.removeAll()
        isPlaying = false
    }

    func playSong() {
        if currItem != player.currentItem {
            time = CMTime.zero
        }
        player.seek(to: time)
        player.play()
        isPlaying = true
        isPlaylistPlaying = false
    }
    
    func pauseSong() {
        currItem = player.currentItem
        time = player.currentTime()
        player.pause()
        isPlaying = false
        isPlaylistPlaying = false
    }
    
    func playAllSongs() {
        player.seek(to: time)
        player.play()
        isPlaying = true
        isPlaylistPlaying = true
    }
    
    func stopSong() {
        player.pause()
        player.seek(to: CMTime.zero)
    }
    
    func nextSong() -> PFObject {
        let currPlayerItem = player.currentItem
        
        //gets the index of the previous player item
        var index = 0
        for playerItem in playerItems {
            if playerItem.value == currPlayerItem {
                index = filenames.firstIndex(of: playerItem.key)! + 1
                print("index: \(index)")
                break
            }
        }
        
        //sets the current player time to the next playerItem
        if index >= (filenames.count - 1) {
            index = 0
        }
        let filename = filenames[index]
        print("song: \(filename)")
        let playerItem = playerItems[filename] as! AVPlayerItem
        
        player.replaceCurrentItem(with: playerItem)
        player.seek(to: CMTime.zero)
        player.play()
        
        return songs[index]
    }
    
    func prevSong() -> PFObject {
        let currPlayerItem = player.currentItem
        
        //gets the index of the previous player item
        var index = 0
        for playerItem in playerItems {
            if playerItem.value == currPlayerItem {
                index = filenames.firstIndex(of: playerItem.key)! - 1
                print("index: \(index)")
                break
            }
        }
        
        //sets the current player time to the previous playerItem
        if index <= 0 {
            index = filenames.count-1
        }
        let filename = filenames[index]
        print("song: \(filename)")
        let playerItem = playerItems[filename] as! AVPlayerItem
        
        player.replaceCurrentItem(with: playerItem)
        player.seek(to: CMTime.zero)
        player.play()
        
        return songs[index]
    }
    
    
}
