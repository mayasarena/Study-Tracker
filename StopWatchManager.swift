//
//  FastingManager.swift
//  StudyTracker
//
//  Created by Maya Murad on 2022-09-21.
//

import Foundation
import SwiftUI

enum stopWatchMode {
    case running
    case stopped
    case paused
}

// MARK: STILL NEED TO MAKE STOPWATCH CONTINUE COUNTING WHILE CLOSED!!!

class StopWatchManager: ObservableObject {
    
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var mode: stopWatchMode = .stopped
    
    var timer = Timer()
    
    var startTime = Date()
    var endTime = Date()
    
    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    let IS_COUNTING_KEY = "isCounting"
    

    
    init() {
        if userDefaults.bool(forKey: IS_COUNTING_KEY) {
            print(userDefaults.object(forKey: START_TIME_KEY) ?? Date())
            print(Date())
            print("timer running")
            let startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
            let difference = (startTime ?? Date()).timeIntervalSinceNow
            self.secondsElapsed = Int(difference * -1)
            start()
        }
        else {
            print("timer not running")
            stop()
        }
    }
    
    func setSecondsElapsed(time: Int) {
        secondsElapsed = time
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> String {
        let hour = "\(seconds / 3600)"
        let min = "\((seconds % 3600) / 60)"
        let sec = "\((seconds % 3600) % 60)"
        let hourStamp = hour.count > 1 ? hour : "0" + hour
        let minStamp = min.count > 1 ? min : "0" + min
        let secStamp = sec.count > 1 ? sec : "0" + sec
        if Int(hour) == 0 {
            return "\(minStamp):\(secStamp)"
        }
        return "\(hourStamp):\(minStamp):\(secStamp)"
    }
    
    func start() {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            timer in self.secondsElapsed += 1
        }
    }
    
    func stop() {
        timer.invalidate()
        secondsElapsed = 0
        mode = .stopped
        NotificationManager.instance.cancelTimerReminderNotification()
    }
    
    func pause() {
        timer.invalidate()
        mode = .paused
    }
}
