//
//  SoundManager.swift
//  StudyTrackerOfficial
//
//  Created by Maya Murad on 2023-01-05.
//

import Foundation
import SwiftUI
import AVKit

class SoundManager {
    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case button_click_1
        case button_click_ok
        case button_click_cancel
        case study_done
        case under_5_min
    }
    
    func playSound(sound: SoundOption) {
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print ("Error playing sound: \(error.localizedDescription)")
        }
    }
}
